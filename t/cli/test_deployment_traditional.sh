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

. ./t/cli/common.sh

echo '
deployment:
    role: traditional
    role_traditional:
        config_provider: etcd
' > conf/config.yaml

out=$(make init 2>&1 || true)
if ! echo "$out" | grep 'invalid deployment traditional configuration: property "etcd" is required'; then
    echo "failed: should check deployment schema during init"
    exit 1
fi

echo "passed: should check deployment schema during init"

# HTTP
echo '
deployment:
    role: traditional
    role_traditional:
        config_provider: etcd
    etcd:
        prefix: "/apisix"
        host:
            - http://127.0.0.1:2379
' > conf/config.yaml

make run
sleep 1

code=$(curl -o /dev/null -s -w %{http_code} http://127.0.0.1:9080/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1')
make stop

if [ ! $code -eq 200 ]; then
    echo "failed: could not connect to etcd with http enabled"
    exit 1
fi

# Both HTTP and Stream
echo '
apisix:
    enable_admin: true
    stream_proxy:
        tcp:
            - addr: 9100
deployment:
    role: traditional
    role_traditional:
        config_provider: etcd
    etcd:
        prefix: "/apisix"
        host:
            - http://127.0.0.1:2379
' > conf/config.yaml

make run
sleep 1

code=$(curl -o /dev/null -s -w %{http_code} http://127.0.0.1:9080/apisix/admin/routes -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1')
make stop

if [ ! $code -eq 200 ]; then
    echo "failed: could not connect to etcd with http & stream enabled"
    exit 1
fi

# Stream
echo '
apisix:
    enable_admin: false
    stream_proxy:
        tcp:
            - addr: 9100
deployment:
    role: traditional
    role_traditional:
        config_provider: etcd
    etcd:
        prefix: "/apisix"
        host:
            - http://127.0.0.1:2379
' > conf/config.yaml

make run
sleep 1

if grep '\[error\]' logs/error.log; then
    echo "failed: could not connect to etcd with stream enabled"
    exit 1
fi

echo "passed: could connect to etcd"
