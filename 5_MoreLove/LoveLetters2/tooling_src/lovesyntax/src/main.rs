#[macro_use]
extern crate structopt;

extern crate syntect;
extern crate git2;
extern crate patch;

use syntect::parsing::{SyntaxDefinition, SyntaxSet};
use syntect::highlighting::{Color, ThemeSet, Theme};
use syntect::html::{styles_to_coloured_html, IncludeBackground};
use syntect::easy::HighlightLines;

use git2::Repository;

use std::str;
use std::path::PathBuf;
use std::fmt::Write;
use std::cmp::max;

use structopt::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt(name = "lovesyntax")]
struct Opt {
    /// Where is the repo
    #[structopt(short = "r", long = "repo")]
    repo: String,

    /// What is the commit sha
    #[structopt(short = "c", long = "commit")]
    commit_id: String,

    /// Do you want HTML Output?
    #[structopt(short = "h", long = "html")]
    as_html: bool,

    /// Which theme do you want to use?
    /// Use "dark" or "bright"
    #[structopt(short = "t", long = "theme", default_value = "bright")]
    theme: String
}

enum DiffLineType {
    Addition,
    Deletion,
    Context
}

impl DiffLineType {
    fn from_symbol(symbol: &char) -> Option<DiffLineType> {
        match *symbol {
            ' ' => Some(DiffLineType::Context),
            '=' => Some(DiffLineType::Context),
            '+' => Some(DiffLineType::Addition),
            '-' => Some(DiffLineType::Deletion),
            '>' => Some(DiffLineType::Addition),
            '<' => Some(DiffLineType::Deletion),
            _ => None
        }
    }
    fn symbol(&self) -> &'static str {
        match self {
            DiffLineType::Addition => "+",
            DiffLineType::Deletion => "-",
            DiffLineType::Context => "",
        }
    }
}
trait DiffWriter {
    fn begin_write(&self);
    fn begin_file(&self, filename: &PathBuf);
    fn write_line(&self, filename: &PathBuf, lines: &Vec<(u32, DiffLineType, String)>);
    fn end_file(&self);
    fn end_write(&self);
}

struct HTMLDiffWriter<'a> {
    syntax_set: SyntaxSet,
    theme_set: ThemeSet,
    theme: &'a str,
}

impl<'a> HTMLDiffWriter<'a> {
    fn new(theme_name: &'a str) -> HTMLDiffWriter {
        let ss = SyntaxSet::load_defaults_nonewlines();
        let ts = ThemeSet::load_defaults();
        HTMLDiffWriter {
            syntax_set: ss,
            theme_set: ts,
            theme: theme_name
        }
    }

    fn highlighted_snippet_for_string(lines: &Vec<(u32, DiffLineType, String)>, syntax: &SyntaxDefinition, theme: &Theme) -> String {
        let mut output = String::new();
        let mut highlighter = HighlightLines::new(syntax, theme);
        let bg_color = theme.settings.background.unwrap_or(Color::BLACK);
        let df: u8 = 10;
        let df2: u8 = 30;
        let abg_color = Color{r: max(0, bg_color.r - df), g: max(0, bg_color.g - df), b: max(0, bg_color.b - df), a: 255};
        let rbg_color = Color{r: max(0, bg_color.r - df2), g: max(0, bg_color.g - df2), b: max(0, bg_color.b - df2), a: 255};
        write!(output, "<pre>\n").unwrap();
        for (line_nr, decoration, line) in lines {
            let symbol = decoration.symbol();
            let (cls, clr) = match decoration {
                DiffLineType::Addition => ("addition", bg_color),
                DiffLineType::Deletion => ("deletion", abg_color),
                DiffLineType::Context => ("", rbg_color),
            };
            let regions = highlighter.highlight(&line);
            let html = styles_to_coloured_html(&regions[..], IncludeBackground::No);
            output.push_str(&format!("<div style=\"background-color: rgb({}, {}, {});\"><span class='t {}'>{} {}</span> ", clr.r, clr.g, clr.b, &cls, &symbol, line_nr));
            output.push_str(&html);
            output.push_str("</div>\n");
        }
        output.push_str("</pre>\n");
        output
    }
}

impl<'a> DiffWriter for HTMLDiffWriter<'a> {
    fn begin_write(&self) {
        let style = "
        * {
          font-family: \"San Francisco\", Helvetica, Sans-Serif;
        }
        span.t {
            background-color: black;
            color: white;
            font-weight: bold;
            width: 32px;
            margin-right: 5px;
        }
        span.deletion {
            background-color: red;
        }
        span.addition {
            background-color: green;
        }
        pre {
            font-size:13px;
            font-family: Consolas, \"Liberation Mono\", Menlo, Courier, monospace;
        }";
        println!("<head><style>{}</style></head>", style);
        println!("<body>\n");
    }

    fn begin_file(&self, filename: &PathBuf) {
        let theme = &self.theme_set.themes[self.theme];
        let c = theme.settings.background.unwrap_or(Color::WHITE);
        if let Some(f) = filename.file_name().and_then(|x| x.to_str()) {
		println!("<h2>{}</h2>", f);
        }
        if let Some(f) = filename.to_str() {
		println!("<h7>{:?}</h7>", f);
        }
        println!("<div style=\"background-color:#{:02x}{:02x}{:02x};\">\n", c.r, c.g, c.b);
    }

    fn write_line(&self, filename: &PathBuf, lines: &Vec<(u32, DiffLineType, String)>) {
        let theme = &self.theme_set.themes[self.theme];
        let extension = filename.extension().and_then(|ext| ext.to_str())
            .unwrap_or("js");
        let syntax = self.syntax_set.find_syntax_by_extension(&extension)
            .unwrap_or(self.syntax_set.find_syntax_by_extension("js").unwrap());
        println!("{}", HTMLDiffWriter::highlighted_snippet_for_string(lines, &syntax, &theme));
    }

    fn end_file(&self) {
        println!("</div>");
    }

    fn end_write(&self) {
        println!("</body>");
    }
}

fn process(repo_path: &str, oid_str: &str, theme_name: &str) {
    let oid = match git2::Oid::from_str(oid_str) {
        Ok(oid) => oid,
        Err(e) => panic!("no valid oid: {}", e)
    };
    let repo = match Repository::open(repo_path) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open repository: {}", e),
    };
    let commit = match repo.find_commit(oid) {
        Ok(commit) => commit,
        Err(e) => panic!("failed to find commit {}\n: {}", oid_str, e)
    };
    let commit_tree1 = match commit.tree() {
        Ok(tree) => tree,
        Err(e) => panic!("Can't find tree for commit: {}", e)
    };
    let commit_parent = match commit.parent(0) {
        Ok(parent) => parent,
        Err(e) => panic!("Can't find parent commit: {}", e)
    };
    let commit_tree2 = match commit_parent.tree() {
        Ok(tree) => tree,
        Err(e) => panic!("Can't find parent commit tree: {}", e)
    };
    let diff = match repo.diff_tree_to_tree(Some(&commit_tree2), Some(&commit_tree1), None) {
        Ok(diff) => diff,
        Err(e) => panic!("No diff: {}", e)
    };

    let writer = HTMLDiffWriter::new(&theme_name);

    writer.begin_write();

    let mut current_file: Option<PathBuf> = None;
    let mut current_lines: Vec<(u32, DiffLineType, String)> = Vec::new();
    diff.print(git2::DiffFormat::Patch, |delta, _hunk, line| {
        let line_type = match DiffLineType::from_symbol(&line.origin()) {
            Some(t) => t,
            None => return true
        };

        let filename = match delta.new_file().path()
            .and_then(|path|path.to_str()) {
            Some(path) => PathBuf::from(path),
            None => return true
        };

        {
            if let Some(existing) = &current_file {
                if existing != &filename {
                    writer.write_line(&filename, &current_lines);
                    writer.end_file();
                    writer.begin_file(&filename);
                    current_lines.clear();
                }
            }
        }
        if current_file.is_none() {
            writer.begin_file(&filename);
        }
        current_file = Some(filename);

        let line_nr = line.old_lineno().unwrap_or(line.new_lineno().unwrap_or(0));
        match str::from_utf8(&line.content()) {
            Ok(contents) => current_lines.push((line_nr, line_type, contents.to_owned())),
            Err(_) => return true
        };
        return true;
    }).expect("Could not write out");
    writer.end_file();
    writer.end_write();
}

fn main() {
    let opt = Opt::from_args();
    let theme = match &opt.theme.as_str() {
        &"dark" => "base16-ocean.dark",
        _ => "InspiredGitHub",
    };
    process(&opt.repo, &opt.commit_id, &theme);
}
