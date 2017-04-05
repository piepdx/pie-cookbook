# Publish to Federated Wiki
These scripts provide a tuneable transformation from the draft markdown to federated wiki json schema.
We expect to rerun the translations throughout the beta period as the work and the transformer evolve.
The book's 1.0 release will become the starting point for divergent evolution within the federation.
We hope that the best contributions there find there way back here to github.

[pie.fed.wiki](http://pie.fed.wiki)

# Operation
Install wiki for local preview.
```
npm install -g wiki
```
Transform and preview result at localhost:3010
```
ruby transform.rb
sh preview.sh
```
Publish with sufficent ssh credentials.
```
sh publish.sh
```

# Method
We use the outline formatter to understand how the work has been organized and what whole-line markdown has been employed.
We map this to wiki story items by adjusting code in the transformer.
We've authored several pages in wiki and saved copies of them in the welcome directory so that they survive retransformations.

Issues specific to wiki or this transformation process are wecome in this [github fork](https://github.com/WardCunningham/pie-cookbook).
