# network-pivotal-io-download

## Download Mode

The script requests product and stemcell images from the **Pivotal Network**

Get your API_TOKEN from https://network.pivotal.io/users/dashboard/edit-profile and pass in on command line to this script, for example:

```
API_TOKEN=DctsxNhqDc4RLqxZExYx ./network-pivotal-io-download.sh student-files1.txt student-files2.txt
```

The script expects text file arguments or STDIN lines formatted as space-delimited pairs of **[FILE_NAME] [API_DOWLOAD_URI]** where these values are obtained by selecting the (i) INFO icon for the associated Pivotal Network download, for example:

```
pcf-vsphere-1.11.3.ova https://network.pivotal.io/api/v2/products/ops-manager/releases/5930/product_files/23671/download
cf-1.11.1-build.6.pivotal https://network.pivotal.io/api/v2/products/elastic-runtime/releases/5903/product_files/23528/download
... and so on
```

## Import Mode

**NOTE: Import Mode is intended for use with Ops Manager VMs installed on localhost _only_**

As per **Download Mode**, except we subsequently attempt to import all downloaded products and stemcells to Ops Manager VM residing on the **localhost**.  As such, in addition to the API_TOKEN, **Import Mode** also requires OPSMAN_USER and OPSMAN_PASSWD to be passed in on the command line, for example:

```
API_TOKEN=DctsxNhqDc4RLqxZExYx OPSMAN_USER=admin OPSMAN_PASSWD=MAvCHePSxJSl! ./network-pivotal-io-download.sh student-files1.txt student-files2.txt
```

To preserve space on the Ops Manager VM, as soon as products and stemcells are imported, their download file gets squashed to a 1-byte file and deposited in the imported directory.
