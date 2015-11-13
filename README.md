t# crypt

## What is this thing?

crypt is a simple tool to help developers safely store secrets on their local machine. It is primarily used to store passwords, SSH keys, AWS access keys and other sensitive information. It is intended to provide convenient access to the information while still protecting you from accidentally copying it in cleartext to unsecured locations. Of specific concern are automated backups, rsync/scp operations, pushes to public repositories, network filesystems etc.

The goal is to reduce the number of secrets that must be protected on your machine. Much like lastpass and other similar tools the goal is to create one master secret that is used to unlock the other secrets. You then only need to worry about protecting that single secret. The single secret in this case is your private key file and its associated password.

## Isn't this a little paranoid?

Maybe!

## How is this different from Gnome Keyring and other similar tools?

There are lots of tools out there that solves problems like this one. They have their pros and cons. Here's what I like about crypt:

* Provides several ways to minimize the amount of time the data is visible in cleartext. `crypt exec` can be used to temporarily decrypt the data while executing a process, once the process terminates the decrypted data is automatically removed.
* Easy to integrate with other tools, you can do stuff like: `crypt cat password/facebook | xclip`.
* Protect arbitrary data, not just passwords. This includes configuration files, environment variables etc.
* Easier to use on different platforms (like Mac OS X).

## What do I need to run it?

Just gpg and python 2.7

## Quickstart

1. Ensure you have a gpg key. See the section below on setting up GPG if you haven't already.
2. Put the crypt script in a directory that is on your PATH.
3. Run `crypt init` and give it a list of public key names. The owners of these keys will be able to decrypt the secrets, you will typically just want to use your own public key name here.
4. Start adding secrets! You can do so by running `crypt add <file containing secrets> <path inside the crypt>`.


## Optional Additional Configuration
1. Enable bash auto-completion by copying crypt-bash-completions.sh to /etc/bash\_completion.d/ and sourcing that file.
2. Configure your screen lock to restart your gpg-agent. You can do this by running `gpgconf --reload gpg-agent`. Anytime you lock your screen, you will have to enter the password for your private key before using any secrets in the crypt.

## Example: protecting your AWS credentials

Create a file in the crypt to store your aws credentials using the command:

```bash
crypt edit aws/creds
```

This will open your editor. Insert the following content, save the file, and then close the editor:

```bash
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY ID GOES HERE>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET ACCESS KEY GOES HERE>
```

Now it should appear in your crypt:

```bash
crypt ls
```

Create a wrapper for the AWS CLI that uses the credentials in the crypt, lets call it `admin_aws`:

```bash
#!/bin/bash

# This command will decrypt the file containing the credentials and define them in the environment of the "aws" subprocess.
crypt exec --env aws/cred aws "$@"
```

Now anytime you run `admin_aws` you will first have to decrypt the credentials using your private key password! Now you don't have to worry about accidentally copying your ~/.aws/config file off of your machine.
