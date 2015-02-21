Glukloader
==========

Glukloader is the OS X desktop uploader of Dexcom G4 Platinum data to [Glukit](http://www.mygluk.it/). It uses 
[bloodSheltie](https://github.com/alexandre-normand/bloodSheltie) to read and decode the data from the Dexcom.

The built and functional app can be downloaded [here](http://www.mygluk.it/).
  
Development
-----------

Glukloader expects a `GlukitSecrets.h` with the CLIENT_ID and CLIENT_SECRET to glukit there.
Something like:

```
#define CLIENT_ID_VALUE @"id"
#define CLIENT_SECRET_VALUE @"secret"
```

To build a release, you'll need [DropDMG](http://c-command.com/dropdmg/) and you can use `./script/release`.

