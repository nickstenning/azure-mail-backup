# Azure mail backup

This repository contains the tools and configuration for my automatic mail
backup system.

For years I've synced my mail to a local [Maildir] using the wonderful
[OfflineIMAP]. This Maildir is also a git repository, which allows me to
reproduce the state of my mailbox at any point in the past, and gives me a great
deal of confidence that none of the backup tooling will accidentally lose email.

Until recently, this setup has been running on a VM in [Linode] which was up
24/7/365. This repository contains the code necessary to set up a VM in Azure
which serves the same purpose and runs only when needed.

[Linode]: https://www.linode.com
[Maildir]: https://en.wikipedia.org/wiki/Maildir
[OfflineIMAP]: https://www.offlineimap.org

## Design

The git repository is stored on a Azure [Managed Disk], which is attached to a
VM.

The VM is booted once an hour by an Azure Function on a [Timer trigger]. On
boot, it fetches the latest updates from my mail account and writes them to the
git repository. When it's done, it shuts down. This whole process typically
takes less than 2 minutes, which means the VM only runs for about 24h in a
month.

[Managed Disk]: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/managed-disks-overview
[Timer trigger]: https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-timer

There are three components to this setup stored in this repository:

1. `docker/`: A Docker image containing [OfflineIMAP] and a script to manage the
   git repo.
2. `function/`: The source of an Azure Function to periodically boot the VM.
3. `createvm`: A script which uses the [Azure CLI] to create and configure an
   appropriate VM. You should create a resource group and managed disk by hand
   (i.e. through the Azure Portal) before running `createvm`.

[Azure CLI]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

## Costs

`createvm` will set up a `Standard_B2s` VM. Running one of these for 24h costs
just over $1 as of August 2019, so I expect this setup to run about $1/month in
compute costs.

Additional costs apply for the managed data disk and the OS disk. The default OS
disk will cost $5.28/mo.

## How to use this

Here's a rough outline of how to adapt this setup for yourself:

1. Create a resource group and a managed disk within that resource group.
2. Run `createvm`.
3. Connect to the VM and follow the instructions in `/opt/mailbackup/README`.
4. Create an Azure AD service principal, and create a secret for it.
5. Grant that service principal "Contributor" permissions on the resource group.
   (You may be able to get away with more restrictive permissions -- it needs
   the ability to list resources in the resource group and start a VM.)
6. Set up an Azure Function App using the code in `function/`.
7. Configure the Function App. You'll need to set the following application settings:
   - `SP_USERNAME` should be the service principal ID (e.g. the AAD Application ID)
   - `SP_PASSWORD` should be the service principal secret
   - `SP_TENANTID` should be the service principal tenant ID
   - `VM_RESOURCE_GROUP` should be the name of the resource group in which you
     created the VM.

Note that you'll certainly need to edit
`/opt/mailbackup/etc/offlineimaprc.template` and
`/opt/mailbackup/etc/docker.env` on the VM to suit your needs.

## License

Everything in this repository is shared without warranty under the terms of the
2-Clause BSD License, a copy of which is provided in `LICENSE`.
