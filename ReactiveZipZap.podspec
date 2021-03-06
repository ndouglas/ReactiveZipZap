Pod::Spec.new do |s|
  s.name         			= "ReactiveZipZap"
  s.version      			= "1.0.14"
  s.summary      			= "Bridging ZipZap to ReactiveCocoa with some hopefully useful things."
  s.description  			= <<-DESC
                            Bridging ZipZap to ReactiveCocoa with some hopefully useful things.
	
					        ZIP files don't include extended attributes. For my purposes,
					        archiving and unarchiving them is absolutely necessary, so, I've
					        added in some code that archives and unarchives these in a (hopefully)
					        useful and painless way.
	
					        I also tend to use ZIP files in network file transfer situations where
					        it may be odious to transfer a few hundred small files in separate
					        requests, so I'm also trying to make it easy to create archives in
					        temporary locations that can be easily deleted when the archive is no
					        longer needed.
               				DESC
  s.homepage     			= "https://github.com/ndouglas/ReactiveZipZap"
  s.license      			= { :type => "Public Domain", :file => "LICENSE" }
  s.author             		= {
                                "Nathan Douglas" => "ndouglas@devontechnologies.com"
                            }
  s.ios.deployment_target 	= "7.0"
  s.osx.deployment_target 	= "10.8"
  s.source       			= {
                                :git => "https://github.com/ndouglas/ReactiveZipZap.git",
                                :branch => "master"
                            }
  s.subspec 'Core' do |cs|
  	cs.exclude_files 		= "*.Tests.m"
  	cs.source_files  		= "*.{h,m}"
	cs.dependency			'zipzap'
	cs.dependency			'ReactiveCocoa'
	cs.requires_arc			= true
  end
  s.subspec 'Tests' do |ts|
	ts.source_files			= "*.Tests.m"
	ts.frameworks			= "XCTest"
	ts.dependency			"ReactiveZipZap/Core"
  end
  s.default_subspec			= "Core"
end
