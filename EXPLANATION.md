## How I did it

After talking to Santi I decided to implement the solution using technologies that Cabify currently uses.

Everything is provisioned by Ansible, including builds and deploys, so a simple `vagrant up` should do the trick.
On my laptop and home connection the initial deployment takes less than five minutes.

### The one-line overview

The Cabify app is deployed to a Nomad cluster and then consul-template dynamically configures HAProxy to use the containers as backend.

### Cabify

I containerised the Cabify app using Ansible's [`docker_image` module](https://docs.ansible.com/ansible/docker_image_module.html). To keep it simple, I'm installing a [`Dockerfile`](/roles/cabify/files/Dockerfile) and then building the image based on that. It is worth noting that you can [build a new version](/roles/cabify/defaults/main.yml#L3) while [keeping the old one running](/roles/cabify/defaults/main.yml#L4), if needed.

### Nomad

I'm running Nomad in dev mode, the same way as Consul. This allows me to easily manage the lifecycle of the Cabify containers, including deploying a new version with zero downtime.

The Cabify job manages the `cabify` service in Consul and has an HTTP healthcheck to monitor the containers status.

By default [7 replicas](/roles/cabify/defaults/main.yml#L6) of the Cabify app.

### Docker registry

To store the Cabify container images I'm running a Docker registry in Nomad and exposing port 5000 locally.
No encryption, no authentication. Not exactly what you'd run in production.
This is required because Nomad needs a registry in order to pull images to then run.

A little bit of synchronisation is needed in Ansible to have everything ready at the right time but it's not a big deal.

### Consul-template

Consul-template runs as a system service and monitors the configuration files in stored in `/etc/consul-template.d/services/`.
It renders the HAProxy configuration dynamically based on the `cabify` service in Consul.

I thought about running it inside Nomad but then it gets complicated to reload HAProxy from there.

## SPOFs

Everything is running on a single node. That the first macroscopic SPOF.

Obviously Consul and Nomad are running in dev mode so everything will wipe out following a restart.
Having real, distibuted clusters will be the next step.

HAProxy is also a SPOF being a single instance. Ideally we should run many instances for redundancy and load distribution.

## Improvements

Aside from the obvious architectural improvements in regards of high availability, load balancing, disaster recovery and so on, I would hook this up to the SCM repository where the application is being developed. By using webhooks and some CI tooling I would create a continuous delivery/deployment solution that will automatically create multiple environments based on branches, including the produciton one.

Also, there is no monitoring whatsoever and there are many moving parts that can fail.

Finally, logs should be shipped to a central collector for aggregation and more detailed metrics. Bonus points for never touching the local disks.

## Questions

* Why Ubuntu 14.04?

## Known issues

* The first time you run `vagrant provision` you'll see a change in `/var/lib/nomad`. This does nothing and it will go away at the next run.
* Log files aren't rotated.
