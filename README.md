# crypt

## What is this thing?

crypt is a simple tool to help developers safely store secrets on their local machine. It is primarily used to store passwords, SSH keys, AWS access keys and other sensitive information. It is intended to provide convenient access to the information while still protecting you from accidentally copying it in cleartext to unsecured locations. Of specific concern are automated backups, rsync/scp operations, pushes to public repositories, network filesystems etc.

The goal is to reduce the number of secrets that must be protected on your machine. Much like Lastpass and other similar tools the goal is to create one master secret that is used to unlock the other secrets. You then only need to worry about protecting that single secret. The single secret in this case is your private key file and its associated password.

## Is this just a case of you being overly paranoid?

Maybe!

## What do I need to run it?

Just gpg and python.

## Quickstart

1. Ensure you have a gpg key. See the section below on setting up GPG if you haven't already.
2. Put the crypt script in a directory that is on your PATH.
3. Run `crypt init` and give it a list of public key names. The owners of these keys will be able to decrypt the secrets, you will typically just want to use your own public key name here.
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


## Setting up GPG

First you will need to install gpg. On Ubuntu this is simple as `sudo apt-get install gnupg`.

Next you will need to generate your private key:

```bash
gpg --gen-key
```

This will ask you several questions, be sure to choose a key length of 2048 or greater and a strong passphrase, longer is better to prevent brute force attacks. Note that if you forget this passphrase you will lose access to all of the associated secrets.

Next export your private key, public key and revocation certificate to a thumbdrive and store them in a physically secure location.

```bash
# public key
gpg --export --output /path/to/thumbdrive/mykey.pub -a mykey
# private key
gpg --export-secret-key --output /path/to/thumbdrive/mykey.key -a mykey
# revocation certificate
gpg --output /path/to/thumbdrive/revoke_mykey.asc --gen-revoke mykey
```
