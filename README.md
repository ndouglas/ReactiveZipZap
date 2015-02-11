# ReactiveZipZap
Bridging ZipZap to ReactiveCocoa with some hopefully useful things.

ZIP files don't include extended attributes.  For my purposes, archiving and unarchiving them is absolutely necessary; 
consequentially, I've added in some code that archives and unarchives these in a (hopefully) useful and painless way.

I also tend to use ZIP files in network file transfer situations where it may be odious to transfer a few hundred small
files in separate requests, so I'm also trying to make it easy to create archives in temporary locations that can be
easily deleted when the archive is no longer needed.'
