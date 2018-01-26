# bosh-stop-start

## What?

`bosh-stop-start.sh` is a bash script for gracefully **stop**ping or **start**ing all the VMs in PCF installations.

## Why?

Idle VMs are expensive to keep running in public cloud environments.

Attempts to stop VMs using IaaS primitives (e.g. `gcloud compute instances stop vm-01234567-89ab-cdef-0123-456789abcdef`) usually end badly.  This is because the BOSH director VM always wants to maintain the lifecycle of its deployments (i.e. tiles).  Not surprising when you consider that lifecycle management is a core responsibility of BOSH.  So it's advisable to politely ask BOSH when you'd like to instruct an installation to go to sleep or wake up.

## How?

We recommend you SSH to the Ops Manager, `git clone` this repo and run the `bosh-stop-start.sh` script from there.

There are two operational modes, `stop` and `start`, which do much as you would expect.

You should expect these operations to each take **~90 mins** to complete.

### Stopping an running installation

```no-highlight
OPSMAN_URL=https://pcf.myinstance.mydomain.com \
OPSMAN_USER=usually_admin \
OPSMAN_PASSWD=some_long_complex_admin_password \
  ./bosh-stop-start.sh stop
```

### Starting an stopped installation

```no-highlight
OPSMAN_URL=https://pcf.myinstance.mydomain.com \
OPSMAN_USER=usually_admin \
OPSMAN_PASSWD=some_long_complex_admin_password \
  ./bosh-stop-start.sh start
```

## Technical notes

* The script uses the [OM](https://github.com/pivotal-cf/om) tool and the [JQ](https://stedolan.github.io/jq/) parser.

* Use the Ops Manager as a host for this script.  If the script fails to connect to the BOSH director private IP address then the operation will be aborted.  Assigning the BOSH director a public IP address is never recommended.

* An added complication arises in automating these tasks because in order to `stop` or `start` the entire installation the script must target each deployment in turn.  Individual deployment names are randomised between each installation so we can't reliably predict them.  To `stop` or `start` an installation we must first ask the system to list all its deployments so that we can successfully target each one.

* We intentionally use `bosh stop --hard` to send an installation to sleep.  The basic `stop` command simply tells the BOSH director to stop all deployed jobs (i.e. processes) but, rather oddly, leaves all the VMs running which continue to incur costs.  At the IaaS level, the `--hard` option translates as a request to stop the jobs **and** delete the VM.  Admittedly this seems a little heavy-handed as we really just wanted the VMs stopped, but it's the only option currently available to us.

* The BOSH director and Ops Manager VMs will remain in a running state after a `stop` operation is completed.  This is intentional.  If necessary these VMs can be manually stopped at the IaaS level but, clearly, they must both be running once again before the issuing a `start` command.