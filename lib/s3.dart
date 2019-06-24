// Copyright (c) 2016, project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:crypto/crypto.dart';

import 'src/request.dart';
import 'src/credentials.dart';

import 'package:http_client/http_client.dart' as http;
import 'package:xml/xml.dart';

/// AWS S3 .
class S3 {
  final Credentials _credentials;
  final http.Client _httpClient;

  /// AWS S3
  S3({Credentials credentials, http.Client httpClient})
      : _credentials = credentials,
        _httpClient = httpClient {
    assert(this._credentials != null);
    assert(this._httpClient != null);
  }

  S3Bucket bucket(BucketUrl bucketUrl) => new S3Bucket(bucketUrl,
      credentials: _credentials, httpClient: _httpClient);
}

///
abstract class BucketUrl {
  ///
  BucketUrl(this._region, this._bucketName) {
    _url = _fixUrl(_region, _bucketName);
  }

  final String _region;
  final String _bucketName;
  String _url;

  String get url => _url;
  String get region => _region;
  String get bucketName => _bucketName;
  String get host;

  String _fixUrl(String region, String bucketName) {
    return 'https://$bucketName.$region.$host/';
  }

  String fullUrl(String path) {
    return '${_url}$path';
  }
}

///
class DOSpacesBucketUrl extends BucketUrl {
  ///
  DOSpacesBucketUrl(String region, String bucketName) :
        super(region, bucketName);

  ///
  String get host => 'digitaloceanspaces.com';
}

/// AWS S3 bucket
class S3Bucket {
  ///
  S3Bucket(
      BucketUrl bucketUrl, {
        Credentials credentials,
        http.Client httpClient,
      })  : _credentials = credentials,
        _httpClient = httpClient,
        _bucketUrl = bucketUrl {
    assert(this._credentials != null);
    assert(this._httpClient != null);
    assert(this._bucketUrl != null);
  }

  final BucketUrl _bucketUrl;
  final Credentials _credentials;
  final http.Client _httpClient;

  String fullUrl(String path) => _bucketUrl.fullUrl(path);

  ///
  Future<AwsResponse> putObject(String key, List<int> body,
      {String contentType, bool private = false}) async {
    AwsResponse response = await AwsRequestBuilder(
      method: 'PUT',
      region: _bucketUrl.region,
      service: 's3',
      baseUrl: _bucketUrl.url + key,
      body: body,
      credentials: _credentials,
      httpClient: _httpClient,
      headers: {
        'Content-Length': body.length.toString(),
        'x-amz-content-sha256': sha256.convert(body).toString(),
        if (contentType?.isNotEmpty == true)
          'Content-Type': contentType,
        'x-amz-acl': private == true ? 'private' : 'public-read'
      }
    ).sendRequest();
    response.validateStatus();

    return response;
  }
}