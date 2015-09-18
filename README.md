# crypt

## What is this thing?

crypt is a simple tool to help developers safely store secrets on their local machine. It is primarily used to store passwords, SSH keys, AWS access keys and other sensitive information. It is intended to provide convenient access to the information while still protecting you from accidentally copying it in cleartext to unsecured locations. Of specific concern are automated backups, rsync/scp operations, pushes to public repositories, network filesystems etc.

The goal is to reduce the number of secrets that must be protected on your machine. Much like Lastpass and other similar tools the goal is to create one master secret that is used to unlock the other secrets. You then only need to worry about protecting that single secret. The single secret in this case is your private key file and its associated password.

## Is this just a case of you being overly paranoid?

Maybe!

## What do I need to run it?

Just gpg and python.

## Quickstart

1. Ensure you have a gpg key. If you don't already have one you can run `gpg --gen-key` and follow the instructions to generate one. Choose a long password that you can remember for your private key password. Note that if you lose this password you will be unable to access any of your own secrets!
2. Set the CRYPT_KEY_NAME environment variable in your `~/.bashrc` or other file that is sourced during initialization. You should set this variable to the name of the public key that will be used to encrypt all of the data.
3. Put the crypt script in a directory that is on your PATH.
4. Start adding secrets! You can do so by running `crypt add <file containing secrets> <path inside the crypt>`.
5. Configure your screen lock to restart your gpg-agent. You can do this by running `gpgconf --reload gpg-agent`. Anytime you lock your screen, you will have to enter the password for your private key before using any secrets in the crypt.

## Example: protecting your AWS credentials

Create a file called "aws-credentials" with the content:

```bash
export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY ID GOES HERE>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET ACCESS KEY GOES HERE>
```

Store this file in the crypt:

```bash
crypt add aws-credentials aws/creds
```

Now it should appear in your crypt:

```bash
crypt ls
```

Create a wrapper for the AWS CLI that uses the credentials in the crypt, lets call it `admin_aws`:

```bash
#!/bin/bash

eval "$(crypt cat aws/creds)"
aws "$@"
```

Now anytime you run `admin_aws` you will first have to decrypt the credentials using your private key password! Now you don't have to worry about accidentally copying your ~/.aws/config file off of your machine.
