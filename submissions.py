#!/usr/bin/env python3

import csv
import os
import subprocess
import sys
import argparse
from pathlib import Path

SEMESTER = "B261"

USERNAME_COLUMN = "Your FIT username"
COMMIT_COLUMN = "The whole commit hash we should consider"

CONTAINER_NAME = "oop-corrector"


def make_git_url(username: str) -> str:
    return f"git@gitlab.fit.cvut.cz:BI-OOP/{SEMESTER}/submissions/{username}.git"


def run_test_container(repository: str, commit: str, output_path: Path):
    """Run the corrector container, echoing its output and saving it to `output_path`."""
    cmd = [
        "docker",
        "run",
        "--mount",
        f"type=bind,source={os.environ['SSH_AUTH_SOCK']},target=/ssh-agent",
        "--env",
        "SSH_AUTH_SOCK=/ssh-agent",
        "--env",
        f"REPOSITORY={repository}",
        "--env",
        f"COMMIT={commit}",
        CONTAINER_NAME,
    ]
    with (
        open(output_path, "w") as output,
        subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
        ) as proc,
    ):
        if proc.stdout:
            for line in proc.stdout:
                sys.stdout.write(line)
                output.write(line)

    if proc.returncode != 0:
        raise subprocess.CalledProcessError(proc.returncode, cmd)


def do_clone(
    username: str,
    commit: str,
    dir: Path,
    *,
    run_docker: bool = False,
):
    repository = make_git_url(username)
    dirname = dir.resolve() / username

    print(f"REPOSITORY={repository}")
    print(f"DIRNAME={dirname}")
    print(f"COMMIT={commit}")

    if dirname.exists():
        print("Already cloned")
    else:
        subprocess.run(
            ["git", "clone", repository, str(dirname)],
            stdout=subprocess.DEVNULL,
            check=True,
        )

    subprocess.run(
        ["git", "checkout", "-b", "Submission", commit],
        cwd=dirname,
        stdout=subprocess.DEVNULL,
        check=True,
    )

    if run_docker:
        run_test_container(repository, commit, dirname / "test_output")


def do_repl(dir: Path):
    try:
        while True:
            username = input("Username\n")
            commit = input("Hash\n")
            try:
                do_clone(username, commit, dir)
            except subprocess.CalledProcessError as e:
                print(e, file=sys.stderr)
    except (EOFError, KeyboardInterrupt):
        print()


def do_csv(csv_path: Path, dir: Path, delimiter: str = ","):
    with csv_path.open(newline="") as f:
        for row in csv.DictReader(f, delimiter=delimiter):
            do_clone(row[USERNAME_COLUMN], row[COMMIT_COLUMN], dir)


def do_build_docker():
    here = Path(__file__).parent.resolve()
    docker_folder = here / "docker"

    subprocess.run(
        [
            "docker",
            "build",
            "--ssh",
            "default",
            "--build-arg",
            f"SEMESTER={SEMESTER}",
            "-t",
            CONTAINER_NAME,
            str(docker_folder),
        ],
        cwd=here,
        check=True,
    )


def main(argv: list[str]) -> int:
    p = argparse.ArgumentParser()

    subp = p.add_subparsers(title="command", required=False, dest="command")

    clonep = subp.add_parser("clone")
    clonep.add_argument("username")
    clonep.add_argument("commit")

    clonep.add_argument("--run-docker", action="store_true")
    clonep.add_argument("--dir", type=Path, default=Path.cwd())

    replp = subp.add_parser("repl")
    replp.add_argument("--dir", type=Path, default=Path.cwd())

    csvp = subp.add_parser("csv")
    csvp.add_argument("file", type=Path)
    csvp.add_argument("--dir", type=Path, default=Path.cwd())

    subp.add_parser("build-docker")

    args = p.parse_args(argv)

    if args.command == "clone":
        do_clone(args.username, args.commit, args.dir, run_docker=args.run_docker)
    elif args.command == "repl":
        do_repl(args.dir)
    elif args.command == "csv":
        do_csv(args.file, args.dir)
    elif args.command == "build-docker":
        do_build_docker()
    else:
        p.print_help()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
