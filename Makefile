
.PHONY: clean setup xcodegen installpods

clean:
	rm -rf DemoApp/DemoApp.xcodeproj
	rm -rf DemoApp/DemoApp.xcworkspace
	rm -rf DemoApp/Pods
	rm -f DemoApp/Podfile.lock

installpods:
	pod install --project-directory=DemoApp --repo-update

xcodegen:
	xcodegen --project DemoApp/

setup: xcodegen installpods

open:
	open DemoApp/DemoApp.xcworkspace