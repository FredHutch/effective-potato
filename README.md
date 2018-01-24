# Using CircleCI, Docker, and Rancher to Deploy a Web Gateway

As with most things, at the core is GitHub.  Webhooks triggered by events here
(merge, push, etc.) are sent to the on-premises CircleCI server
(circle.fhcrc.org) which performs the necessary actions to build pages and
services into a Docker container.  Circle then deploys the updated container to
Rancher.

> This example deploys both the server (nginx) and web pages in the container.
> In this example, I'm using the official nginx container from Docker hub with no
> other changes.  As the volume of data in the web pages is minimal, this
> approach is suitable- however, if the volume of data being deployed is large or
> if building the server/application is a long process, it may be better to build
> these separately so that updating the data won't require rebuilding the server
> or so that the size of the container makes other operations unweildy.

# CircleCI Configuration

In this example we have markdown pages which we need to convert to HTML using
Jekyll.  Starting with the standard Jekyll project layout, we add a CircleCI
configuration file.  Currently we need to use the version 1 syntax.  Refer to
this example for the following discussion.

## `circle.yml` Sections

### `general`:

The only thing indicated here is that we are building _just_ the master branch.
The default behavior will build any branch in the repository.

### `machine`:

This section indicates we need both docker capabilites and Ruby installed
(required for Jekyll).

### `environment`:

This just sets a couple variables we'll use downstream.

### `dependencies`:

We set up the build here- we need to download the rancher-compose client (the
URL for which we will enter as an evnironment variable in the project) and use
`bundle` to install the project dependencies from the Gemfile.  `bundle` is
again used to build the project using Jekyll (converting markdown to HTML and
other functions). Lastly, we build the docker container.

Note that the Dockerfile contains a step where the built site is copied into
the container.

### `test`:

Currently we just echo some stuff out- a more advanced test might start the
container and check that the webpage is served correctly, but for this example
any command that exits 0 will be fine.

### `deployment`:

This step will log into the Docker Hub and push our built images there- both
the TAG and "latest" are pushed though we continually use "latest" in our
deploy.  See "Notes" below.

A 20 second delay is inserted to ensure that the new images are registered in
Docker Hub.  Then we use `rancher-compose` to build the Rancher stack.  This
command will update any existing stack or create it if it does not exist.

> Note: Using the "latest" tag in production isn't likely the best practice. A
> more mature workflow would build a "latest" off of a development branch,
> leaving the production site built from master and a stable tag (a build,
> github tag, or even a "stable" tag).

## Follow the Project

Log in to the Circle application and add the repository to it.  We'll need to add additional environment variables:

  - `DOCKER_USER`: docker hub username
  - `DOCKER_EMAIL`: docker hub verified email for `DOCKER_USER`
  - `DOCKER_PASS`: password for `DOCKER_USER`
  - `RANCHER_API_KEY`: environment API key for the Rancher environment where this will run
  - `RANCHER_API_SECRET`: environment API secret for same
  - `RANCHER_API_URI`: URI for the Rancher environment
  - `RANCHER_DOWNLOAD_URI`: path to download a _tar.gz_ of `rancher-compose`

Obviously, we'll only have some of this information after configuring Rancher.

## Rancher Configuration

The only thing necessary is to create the API key and enter the key and secret into the CircleCI environment variable configuration page.

> NOTE: This is _not_ the standard API key- it is an environment key that is
> available only after opening the "Advanced" link in the API key page.

# Push and Check

Now all that is left is to push your repository to GitHub.  That will trigger
all of the above actions and- if all is well- deploy it to Rancher.  This
example is incomplete at the moment: it doesn't configure the load balancer
that is required to expose this to the network and/or Internet. This will be
the subject of a future update.


