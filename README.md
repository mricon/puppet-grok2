# grok2

#### Table of Contents

1. [Overview](#overview)
2. [Usage - Basic usage](#usage)
3. [Limitations - OS compatibility, etc.](#limitations)

## Overview
A Puppet module for managing deployments of
[Grokmirror](https://github.com/mricon/grokmirror) v2.x

It's a lot slimmer than the puppet module for grokmirror-1.x because,
honestly, puppet is kinda dead and this is such a niche package that writing a
humongous module to manage a couple of config files is just a waste of effort.

## Usage

To use this module you can either directly include it in your module
tree, or add the following to your `Puppetfile`:

```
  mod 'mricon-grok2'
```

## Limitations

Tested on EL 7 and expects a python3-grokmirror package from copr/lfit.
