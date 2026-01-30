fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload metadata to App Store Connect

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Upload IPA to TestFlight

### ios upload_appstore

```sh
[bundle exec] fastlane ios upload_appstore
```

Upload IPA to App Store

### ios release_testflight

```sh
[bundle exec] fastlane ios release_testflight
```

Build and upload to TestFlight

### ios release_appstore

```sh
[bundle exec] fastlane ios release_appstore
```

Build and upload to App Store

----


## Android

### android upload_screenshots

```sh
[bundle exec] fastlane android upload_screenshots
```

Upload screenshots to Play Store

### android upload_metadata

```sh
[bundle exec] fastlane android upload_metadata
```

Upload metadata to Play Store

### android upload_all

```sh
[bundle exec] fastlane android upload_all
```

Upload all metadata, screenshots, and images to Play Store

### android upload_internal

```sh
[bundle exec] fastlane android upload_internal
```

Upload AAB to Internal Testing

### android upload_production

```sh
[bundle exec] fastlane android upload_production
```

Upload AAB to Production

### android release_internal

```sh
[bundle exec] fastlane android release_internal
```

Build and upload to Internal Testing

### android release_production

```sh
[bundle exec] fastlane android release_production
```

Build and upload to Production

### android deploy_internal

```sh
[bundle exec] fastlane android deploy_internal
```

Full deploy: metadata + screenshots + build + internal

### android deploy_production

```sh
[bundle exec] fastlane android deploy_production
```

Full deploy: metadata + screenshots + build + production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
