#[macro_use]
extern crate structopt;
extern crate git2;

#[macro_use]
extern crate serde_derive;

extern crate serde;
extern crate serde_json;

use git2::{Repository, BranchType, Sort};

use std::fmt::LowerHex;
use std::str;
use std::path::PathBuf;
use std::fmt::Write;
use std::cmp::max;

use structopt::StructOpt;

    // fn process(repo_path: &str, branch_name: &str, remote_branch: bool, from_commit: Option<&str>, page_size: u32) {
#[derive(StructOpt, Debug)]
#[structopt(name = "gitreader")]
struct Opt {
    /// Where is the repo
    #[structopt(short = "r", long = "repo")]
    repo: String,

    /// Which branch
    #[structopt(short = "b", long = "branch")]
    branch_name: String,

    /// Is this a remote branch?
    #[structopt(short = "e", long = "remote")]
    branch_remote: bool,

    /// What is the commit sha to continue from
    #[structopt(short = "f", long = "from-commit")]
    from_commit: Option<String>,

    /// How many items to return
    #[structopt(short = "p", long = "page", default_value = "100")]
    page_size: usize
}

fn main() {
    let opt = Opt::from_args();
    process(&opt.repo, &opt.branch_name, opt.branch_remote, opt.from_commit, opt.page_size);
}

#[derive(Serialize, Debug)]
struct Signature {
    name: String,
    email: String
}

impl Signature {
    fn from_signature(signature: git2::Signature) -> Result<Signature, &'static str> {
        let name = match signature.name() {
            Some(s) => s.to_string(),
            None => "Anon".to_string()
        };
        let email = match signature.email() {
            Some(s) => s.to_string(),
            None => "Anon@anon.anon".to_string()
        };
        Ok(Signature {
            name,
            email
        })
    }
}

#[derive(Serialize, Debug)]
struct Commit {
    oid: String,
    message: String,
    summary: String,
    time: i64,
    author: Signature,
    committer: Signature,
    parents: Vec<String>
}

impl Commit {
    fn commit_hash(commit: &git2::Commit) -> String {
        let strs: Vec<String> = commit.id().as_bytes().iter()
                               .map(|b| format!("{:02x}", b))
                               .collect();
        strs.connect("")
    }
    fn from_commit(commit: git2::Commit) -> Result<Commit, &'static str> {
        let oid = Commit::commit_hash(&commit);
        let parents: Vec<String> = commit.parents().map(|p| {
            Commit::commit_hash(&p)
        }).collect();
        let message = match commit.message() {
            Some(s) => s.to_string(),
            None => "".to_string()
        };
        let summary = match commit.summary() {
            Some(s) => s.to_string(),
            None => "".to_string()
        };
        let author = match Signature::from_signature(commit.author()) {
            Ok(a) => a,
            Err(_) => return Err("No author found")
        };
        let committer = match Signature::from_signature(commit.committer()) {
            Ok(a) => a,
            Err(_) => return Err("No committer found")
        };
        Ok(Commit {
            oid,
            message,
            summary,
            time: commit.time().seconds(),
            author,
            committer,
            parents
        })
    }
}


fn process(repo_path: &str, branch_name: &str, remote_branch: bool, from_commit: Option<String>, page_size: usize) {
    let repo = match Repository::open(repo_path) {
        Ok(repo) => repo,
        Err(e) => panic!("failed to open repository: {}", e),
    };
    let from_oid = from_commit.map(|c| {
        match git2::Oid::from_str(&c) {
            Ok(oid) => oid,
            Err(e) => panic!("no valid oid: {} {}", c, e)
        }
    });
    let branch = match repo.find_branch(branch_name, if remote_branch { BranchType::Remote } else { BranchType::Local } ) {
        Ok(branch) => branch,
        Err(e) => panic!("failed to find branch {}\n: {}", branch_name, e)
    };
    let branch_oid = match branch.get().target() {
        Some(oid) => oid,
        None => panic!("failed to find branch oid")
    };
    let mut revwalk = match repo.revwalk() {
        Ok(revwalk) => revwalk,
        Err(e) => panic!("failed to create revwalk\n: {}", e)
    };

    revwalk.set_sorting(Sort::TOPOLOGICAL);
    revwalk.set_sorting(Sort::TIME);
    revwalk.push(branch_oid);

    let commits: Vec<Commit> = revwalk
        .filter_map(|oid| {
            let oid_str = match oid {
                Ok(oid) => oid, 
                Err(_) => return None
            };
            let commit = match repo.find_commit(oid_str) {
                Ok(commit) => commit,
                Err(_) => return None
            };
            Some(commit)
        })
        .skip_while(|commit| {
            let from_oid = match from_oid {
                Some(oid) => oid,
                None => return false
            };
            from_oid != commit.id()
        })
        .skip(if from_oid.is_some() { 1 } else { 0 })
        .filter_map(|commit| {
            Commit::from_commit(commit).ok()
        })
        .take(page_size)
        .collect();

    let serialized = serde_json::to_string(&commits).unwrap();
    println!("{}", serialized);
}

