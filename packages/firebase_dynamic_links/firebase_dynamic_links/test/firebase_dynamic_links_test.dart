// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';

MockFirebaseDynamicLinks mockDynamicLinksPlatform = MockFirebaseDynamicLinks();

DynamicLinkParameters buildDynamicLinkParameters() {
  AndroidParameters android = AndroidParameters(
    fallbackUrl: Uri.parse('test-url'),
    minimumVersion: 1,
    packageName: 'test-package',
  );

  GoogleAnalyticsParameters google = const GoogleAnalyticsParameters(
      campaign: 'campaign',
      medium: 'medium',
      source: 'source',
      term: 'term',
      content: 'content');

  IosParameters ios = IosParameters(
      appStoreId: 'appStoreId',
      bundleId: 'bundleId',
      customScheme: 'customScheme',
      fallbackUrl: Uri.parse('fallbackUrl'),
      ipadBundleId: 'ipadBundleId',
      ipadFallbackUrl: Uri.parse('ipadFallbackUrl'),
      minimumVersion: 'minimumVersion');

  ItunesConnectAnalyticsParameters itunes =
      const ItunesConnectAnalyticsParameters(
    affiliateToken: 'affiliateToken',
    campaignToken: 'campaignToken',
    providerToken: 'providerToken',
  );

  DynamicLinkParametersOptions parametersOptions =
      const DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable);

  Uri link = Uri.parse('link');
  NavigationInfoParameters navigation =
      const NavigationInfoParameters(forcedRedirectEnabled: true);
  SocialMetaTagParameters social = SocialMetaTagParameters(
      description: 'description',
      imageUrl: Uri.parse('imageUrl'),
      title: 'title');

  String uriPrefix = 'https://';

  return DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: link,
      androidParameters: android,
      dynamicLinkParametersOptions: parametersOptions,
      googleAnalyticsParameters: google,
      iosParameters: ios,
      itunesConnectAnalyticsParameters: itunes,
      navigationInfoParameters: navigation,
      socialMetaTagParameters: social);
}

void main() {
  setupFirebaseDynamicLinksMocks();

  late FirebaseDynamicLinks dynamicLinks;

  group('$FirebaseDynamicLinks', () {
    setUp(() async {
      FirebaseDynamicLinksPlatform.instance = mockDynamicLinksPlatform;

      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: '',
          appId: '',
          messagingSenderId: '',
          projectId: '',
        ),
      );

      dynamicLinks = FirebaseDynamicLinks.instance;
    });

    group('getInitialLink', () {
      test('link can be parsed', () async {
        const mockClickTimestamp = 1234567;
        const mockMinimumVersionAndroid = 12;
        const mockMinimumVersionIOS = 'ios minimum version';
        Uri mockUri = Uri.parse('mock-scheme');

        when(dynamicLinks.getInitialLink()).thenAnswer((_) async =>
            TestPendingDynamicLinkData(mockUri, mockClickTimestamp,
                mockMinimumVersionAndroid, mockMinimumVersionIOS));

        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data!.link.scheme, mockUri.scheme);

        expect(data.android!.clickTimestamp, mockClickTimestamp);
        expect(data.android!.minimumVersion, mockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, mockMinimumVersionIOS);

        verify(dynamicLinks.getInitialLink());
      });

      test('for null result, returns null', () async {
        when(dynamicLinks.getInitialLink()).thenAnswer((_) async => null);

        final PendingDynamicLinkData? data =
            await dynamicLinks.getInitialLink();

        expect(data, isNull);

        verify(dynamicLinks.getInitialLink());
      });
    });

    group('getDynamicLink', () {
      test('getDynamicLink', () async {
        final Uri mockUri = Uri.parse('short-link');
        const mockClickTimestamp = 38947390875;
        const mockMinimumVersionAndroid = 21;
        const mockMinimumVersionIOS = 'min version';

        when(dynamicLinks.getDynamicLink(mockUri)).thenAnswer((_) async =>
            TestPendingDynamicLinkData(mockUri, mockClickTimestamp,
                mockMinimumVersionAndroid, mockMinimumVersionIOS));

        final PendingDynamicLinkData? data =
            await dynamicLinks.getDynamicLink(mockUri);

        expect(data!.link.scheme, mockUri.scheme);

        expect(data.android!.clickTimestamp, mockClickTimestamp);
        expect(data.android!.minimumVersion, mockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, mockMinimumVersionIOS);

        verify(dynamicLinks.getDynamicLink(mockUri));
      });
    });

    group('onLink', () {
      test('onLink', () async {
        final Uri mockUri = Uri.parse('on-link');
        const mockClickTimestamp = 239058435;
        const mockMinimumVersionAndroid = 33;
        const mockMinimumVersionIOS = 'on-link version';
        when(dynamicLinks.onLink()).thenAnswer((_) => Stream.value(
            TestPendingDynamicLinkData(mockUri, mockClickTimestamp,
                mockMinimumVersionAndroid, mockMinimumVersionIOS)));

        final PendingDynamicLinkData? data = await dynamicLinks.onLink().first;
        expect(data!.link.scheme, mockUri.scheme);

        expect(data.android!.clickTimestamp, mockClickTimestamp);
        expect(data.android!.minimumVersion, mockMinimumVersionAndroid);

        expect(data.ios!.minimumVersion, mockMinimumVersionIOS);

        verify(dynamicLinks.onLink());
      });
    });

    group('shortenUrl', () {
      test('shortenUrl', () async {
        final Uri mockUri = Uri.parse('shortenUrl');
        final Uri previewLink = Uri.parse('previewLink');
        List<String> warnings = ['warning'];
        const DynamicLinkParametersOptions options =
            DynamicLinkParametersOptions(
                shortDynamicLinkPathLength:
                    ShortDynamicLinkPathLength.unguessable);

        when(dynamicLinks.shortenUrl(mockUri, options)).thenAnswer((_) async =>
            ShortDynamicLink(
                shortUrl: mockUri,
                warnings: warnings,
                previewLink: previewLink));

        final shortDynamicLink =
            await dynamicLinks.shortenUrl(mockUri, options);

        expect(shortDynamicLink.previewLink, previewLink);
        expect(shortDynamicLink.warnings, warnings);
        expect(shortDynamicLink.shortUrl, mockUri);

        verify(dynamicLinks.shortenUrl(mockUri, options));
      });
    });

    group('buildUrl', () {
      test('buildUrl', () async {
        final Uri mockUri = Uri.parse('buildUrl');
        DynamicLinkParameters params =
            DynamicLinkParameters(uriPrefix: 'uriPrefix', link: mockUri);

        when(dynamicLinks.buildUrl(params)).thenAnswer((_) async => mockUri);

        final shortDynamicLink = await dynamicLinks.buildUrl(params);

        expect(shortDynamicLink, mockUri);
        expect(shortDynamicLink.scheme, mockUri.scheme);
        expect(shortDynamicLink.path, mockUri.path);

        verify(dynamicLinks.buildUrl(params));
      });

      test("buildUrl with full 'DynamicLinkParameters' options", () async {
        final Uri mockUri = Uri.parse('buildUrl');
        DynamicLinkParameters params = buildDynamicLinkParameters();

        when(dynamicLinks.buildUrl(params)).thenAnswer((_) async => mockUri);

        final shortDynamicLink = await dynamicLinks.buildUrl(params);

        expect(shortDynamicLink, mockUri);
        expect(shortDynamicLink.scheme, mockUri.scheme);
        expect(shortDynamicLink.path, mockUri.path);

        verify(dynamicLinks.buildUrl(params));
      });
    });

    group('buildShortLink', () {
      test('buildShortLink', () async {
        final Uri mockUri = Uri.parse('buildShortLink');
        final Uri previewLink = Uri.parse('previewLink');
        List<String> warnings = ['warning'];
        DynamicLinkParameters params =
            DynamicLinkParameters(uriPrefix: 'uriPrefix', link: mockUri);
        final shortLink = ShortDynamicLink(
            shortUrl: mockUri, warnings: warnings, previewLink: previewLink);

        when(dynamicLinks.buildShortLink(params)).thenAnswer((_) async =>
            ShortDynamicLink(
                shortUrl: mockUri,
                warnings: warnings,
                previewLink: previewLink));

        final shortDynamicLink = await dynamicLinks.buildShortLink(params);

        expect(shortDynamicLink.warnings, shortLink.warnings);
        expect(shortDynamicLink.shortUrl, shortLink.shortUrl);
        expect(shortDynamicLink.previewLink, shortLink.previewLink);

        verify(dynamicLinks.buildShortLink(params));
      });

      test("buildShortLink with full 'DynamicLinkParameters' options",
          () async {
        final Uri mockUri = Uri.parse('buildShortLink');
        final Uri previewLink = Uri.parse('previewLink');
        List<String> warnings = ['warning'];
        DynamicLinkParameters params = buildDynamicLinkParameters();
        final shortLink = ShortDynamicLink(
            shortUrl: mockUri, warnings: warnings, previewLink: previewLink);

        when(dynamicLinks.buildShortLink(params)).thenAnswer((_) async =>
            ShortDynamicLink(
                shortUrl: mockUri,
                warnings: warnings,
                previewLink: previewLink));

        final shortDynamicLink = await dynamicLinks.buildShortLink(params);

        expect(shortDynamicLink.warnings, shortLink.warnings);
        expect(shortDynamicLink.shortUrl, shortLink.shortUrl);
        expect(shortDynamicLink.previewLink, shortLink.previewLink);

        verify(dynamicLinks.buildShortLink(params));
      });
    });
  });
}

class TestPendingDynamicLinkData extends PendingDynamicLinkData {
  TestPendingDynamicLinkData(mockUri, mockClickTimestamp,
      mockMinimumVersionAndroid, mockMinimumVersionIOS)
      : super(
            link: mockUri,
            android: PendingDynamicLinkDataAndroid(
                clickTimestamp: mockClickTimestamp,
                minimumVersion: mockMinimumVersionAndroid),
            ios: PendingDynamicLinkDataIOS(
                minimumVersion: mockMinimumVersionIOS));
}

final testData = TestPendingDynamicLinkData(Uri.parse('uri'), null, null, null);

Future<PendingDynamicLinkData?> testFutureData() {
  return Future.value(testData);
}

Uri uri = Uri.parse('mock');

class MockFirebaseDynamicLinks extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebaseDynamicLinksPlatform {
  @override
  Future<PendingDynamicLinkData?> getInitialLink() {
    return super.noSuchMethod(
      Invocation.method(#getInitialLink, []),
      returnValue: testFutureData(),
      returnValueForMissingStub: testFutureData(),
    );
  }

  @override
  Future<PendingDynamicLinkData?> getDynamicLink(Uri uri) {
    return super.noSuchMethod(
      Invocation.method(#getDynamicLink, [], {#uri: uri}),
      returnValue: testFutureData(),
      returnValueForMissingStub: testFutureData(),
    );
  }

  @override
  Future<Uri> buildUrl(DynamicLinkParameters parameters) {
    return super.noSuchMethod(
      Invocation.method(#getDynamicLink, [parameters]),
      returnValue: Future.value(Uri.parse('buildUrl')),
      returnValueForMissingStub: Future.value(Uri.parse('buildUrl')),
    );
  }

  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: MockFirebaseDynamicLinks(),
      returnValueForMissingStub: MockFirebaseDynamicLinks(),
    );
  }

  @override
  Future<ShortDynamicLink> shortenUrl(Uri uri,
      [DynamicLinkParametersOptions? options]) {
    return super.noSuchMethod(
      Invocation.method(#shortenUrl, [uri, options]),
      returnValue: Future.value(ShortDynamicLink(
          shortUrl: uri,
          warnings: ['warning'],
          previewLink: Uri.parse('preview'))),
      returnValueForMissingStub: Future.value(ShortDynamicLink(
          shortUrl: uri,
          warnings: ['warning'],
          previewLink: Uri.parse('preview'))),
    );
  }

  @override
  Future<ShortDynamicLink> buildShortLink(DynamicLinkParameters parameters) {
    return super.noSuchMethod(
      Invocation.method(#buildShortLink, [parameters]),
      returnValue: Future.value(ShortDynamicLink(
          shortUrl: uri,
          warnings: ['warning'],
          previewLink: Uri.parse('preview'))),
      returnValueForMissingStub: Future.value(ShortDynamicLink(
          shortUrl: uri,
          warnings: ['warning'],
          previewLink: Uri.parse('preview'))),
    );
  }

  @override
  Stream<PendingDynamicLinkData?> onLink() {
    return super.noSuchMethod(
      Invocation.method(#onLink, []),
      returnValue: Stream.value(testData),
      returnValueForMissingStub: Stream.value(testData),
    );
  }
}

class TestFirebaseDynamicLinksPlatform extends FirebaseDynamicLinksPlatform {
  TestFirebaseDynamicLinksPlatform() : super();

  void instanceFor({
    FirebaseApp? app,
  }) {}

  @override
  FirebaseDynamicLinksPlatform delegateFor({required FirebaseApp app}) {
    return this;
  }
}