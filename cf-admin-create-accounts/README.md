# cf-admin-create-accounts

This script uses the [cf CLI](https://docs.cloudfoundry.org/cf-cli/) to automate the creation of batches of user accounts in the Pivotal Application Service.  It also creates an ORG and SPACE pair for each user.  As such it's important to ensure the invoker of the script is already logged on to the correct Pivotal Application Service instance using an account with elevated rights - preferably an administrative account.

When logging on with the cf CLI, we must _not_ use the Ops Manager admin account but the **UAA** admin account.  You can locate the password from the Ops Manager UI by navigating to the `Pivotal Application Service` tile and opening the `Credentials` tab. Find the `UAA` -> `Admin Credentials` and click on `Link to Credential` to reveal the password.

Log into your target Pivotal Application Service instance using the **UAA Admin** account, for example:

```no-highlight
  cf login -a api.<SYS_ENDPOINT> -u admin --skip-ssl-validation # assuming self-signed certs
```

To create user accounts, pass in a file (or files) containing the required user emails (one per line) to the creation script, for example:

```no-highlight
  ./cf-admin-create-accounts.sh \
  ./user-emails-1.txt \
  ./user-emails-2.txt
```

The script expects an input text file or stdin lines representing an identifier for each user (typically an email), for example:

```no-highlight
# this line will be ignored by cf-admin-create-accounts.sh
sbrin@abc.xyz
emusk@spacex.com
amcginlay@pivotal.io
# ... and so on
```

The script will result in the creation of one PAS `SpaceDeveloper` user per line in the file(s), each with their own like-named ORG and a SPACE named "dev".

For simplicity all users will have their password set to "password"
