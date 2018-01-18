# network-pivotal-io-download

## Download Mode

The script requests product and stemcell images from the **Pivotal Network**

Get your API_TOKEN from https://network.pivotal.io/users/dashboard/edit-profile and pass in on command line to this script, for example:

```
API_TOKEN=DctsxNhqDc4RLqxZExYx ./network-pivotal-io-download.sh student-files1.txt student-files2.txt
```

The script expects an input text file (e.g. student-files.txt) or stdin lines formatted as space-delimited triplets of [PRODUCT_SLUG] [PRODUCT_VERSION] [RELEASE_ID] where these values are obtained by selecting the (i) INFO icon for the associated Pivotal Network download, for example:

```
ops-manager     1.12.5 35440
elastic-runtime 1.12.8 36393
... and so on
```

## Import Mode

As per **Download Mode**, except we subsequently attempt to import all downloaded products and stemcells to Ops Manager VM residing on the **localhost**.  As such, in addition to the API_TOKEN, **Import Mode** also requires OPSMAN_USER and OPSMAN_PASSWD to be passed in on the command line, for example:

```
API_TOKEN=DctsxNhqDc4RLqxZExYx OPSMAN_URL=https://pcf.mydomain.com OPSMAN_USER=admin OPSMAN_PASSWD=MAvCHePSxJSl! ./network-pivotal-io-download.sh student-files1.txt student-files2.txt
```

To preserve space on the Ops Manager VM, as soon as products and stemcells are imported, their download file gets squashed to a 1-byte file and deposited in the imported directory.
