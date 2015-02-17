# My GitHub backups

This is a script which simply runs and regularly backs up my GitHub repositories
because I prefer to have local copies of my things on my server.

# What does it back up?

* Repositories
* Repository wikis
* Gists

# How to configure.

Configure [gitlab-mirrors][gm] to replicate where you want.  I have it
configured so that it mirrors repositories local only with
`no_remote_set=true`.

    cp config.yml.SAMPLE config.yml

And that's it.

Please note, `cron.sh` has a hard coded path because I'm lazy.  It's meant for
cron jobs but feel free to copy/modify it for your own cron jobs.

# How does it compare to gitlab-mirrors

`gitlab-mirrors` does all of the hard work of the actual mirroring.  This
project merely talks to the GitHub API and then passes arguments to
`gitlab-mirrors`.

For this to be effective you need two cron jobs.  One for `gitlab-mirrors` and
one for this project.

[gm]: https://github.com/samrocketman/gitlab-mirrors
