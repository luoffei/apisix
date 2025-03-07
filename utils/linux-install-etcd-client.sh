#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ETCD_ARCH="amd64"
ETCD_VERSION=${ETCD_VERSION:-'3.4.18'}
ARCH=${ARCH:-`(uname -m | tr '[:upper:]' '[:lower:]')`}

if [[ $ARCH == "arm64" ]] || [[ $ARCH == "aarch64" ]]; then
    ETCD_ARCH="arm64"
fi

wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v3.4.18-linux-${ETCD_ARCH}.tar.gz
tar xf etcd-v${ETCD_VERSION}-linux-${ETCD_ARCH}.tar.gz
sudo cp etcd-v${ETCD_VERSION}-linux-${ETCD_ARCH}/etcdctl /usr/local/bin/
rm -rf etcd-v${ETCD_VERSION}-linux-${ETCD_ARCH}
