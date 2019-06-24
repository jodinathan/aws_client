// Copyright (c) 2016, project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_client/http_client.dart' as http;

import 'src/credentials.dart';
import 'sqs.dart';
import 's3.dart';

export 'src/credentials.dart';

/// AWS access facade that helps to initialize multiple services with common
/// settings (credentials and HTTP client).
class Aws {
  final Credentials _credentials;
  final http.Client _httpClient;

  Sqs _sqs;
  S3 _s3;

  ///
  Aws({Credentials credentials, http.Client httpClient})
      : _credentials = credentials,
        _httpClient = httpClient {
    assert(this._credentials != null);
    assert(this._httpClient != null);
  }

  /// Returns an SQS service, inheriting the properties of this instance.
  Sqs get sqs =>
      _sqs ??= new Sqs(credentials: _credentials, httpClient: _httpClient);

  /// Returns an SQS service, inheriting the properties of this instance.
  S3 get s3 =>
      _s3 ??= new S3(credentials: _credentials, httpClient: _httpClient);
}
