---
title: "『Build an Orchestrator in Go (From Scratch)』を読んだ"
date: 2024-09-17
description: ""
external: false
---

有給期間を利用して、[『Build an Orchestrator in Go (From Scratch)』](https://www.manning.com/books/build-an-orchestrator-in-go-from-scratch)という本を読みました。  
文字通り k8s のようなコンテナオーケストレーションツールを Go で作成するというものです。  

## Part 1: Introduction
この章ではオーケストレーションツールが盛んになってきている理由や、オーケストレーターのざっくりとした仕組み、この本で作成する `cube` についての概要が述べられています。

ここでは、オーケストレーションシステムを
- Job
- Task
- Scheduler
- Manager
- Worker
- Cluster
- CLI

といったコンポーネントに分けてそれぞれを説明しています。

そして、上記で説明されたメンタルモデルに合わせて今後、`cube` を実装していきます。

## Part 2: Worker
この章では、Worker (Kubernetes でいう Node) を実装してきます。  

1. Worker の実装
2. Worker とやり取りするための API の実装（Manager のインターフェースとなる部分）
3. Worker の Metrics 収集

この 3 点を実装します。

Worker 本体の実装ですが、タスクの実行に関連したメソッドの作成を通じて行っていきます。  
その後、Worker にタスクを送信したり、タスクを止めたりするための API server を実装します。  
最後に、次の章の Manager に向けて、Worker の Metrics を収集、それらを API を通じて外部に公開します。

この章を終えると、下記のようにタスクの追加、停止を API を通じて行うことができるようになります。

```sh
❯ curl -v --request POST --header 'Content-Type: application/json' --data '{
    "ID": "266592cd-960d-4091-981c-8c25c44b1018",
    "State": 2,
    "Task": {
        "State": 1,
        "ID": "266592cd-960d-4091-981c-8c25c44b1018",
        "Name": "test-chapter-5-1",
        "Image": "strm/helloworld-http"
    }
}' localhost:5555/tasks

{"ID":"266592cd-960d-4091-981c-8c25c44b1018","ContainerID":"","Name":"test-chapter-5-1","State":1,"Image":"strm/helloworld-http","Cpu":0,"Memory":0,"Disk":0,"ExposedPorts":null,"PortBindings":null,"RestartPolicy":"","StartTime":"0001-01-01T00:00:00Z","FinishTime":"0001-01-01T00:00:00Z"}

❯ curl -v localhost:5555/tasks

[
  {
    "ID": "266592cd-960d-4091-981c-8c25c44b1018",
    "ContainerID": "611617ad1566e3e2dfc9266116d583852031947e0fa32c6e68373716b9533ea0",
    "Name": "test-chapter-5-1",
    "State": 2,
    "Image": "strm/helloworld-http",
    "Cpu": 0,
    "Memory": 0,
    "Disk": 0,
    "ExposedPorts": null,
    "PortBindings": null,
    "RestartPolicy": "",
    "StartTime": "2024-09-07T10:40:01.04234Z",
    "FinishTime": "0001-01-01T00:00:00Z"
  }
]

❯ curl -v --request DELETE "localhost:5555/tasks/266592cd-960d-4091-981c-8c25c44b1018"
```

```sh
❯ CUBE_HOST=localhost CUBE_PORT=5555 DOCKER_HOST=unix:///Users/granddaifuku/.orbstack/run/docker.sock go run main.go
Starting Cube worker
2024/09/07 19:38:01 No tasks to process currently.
2024/09/07 19:38:01 Sleeping for 10 secs.
...
...
2024/09/07 19:39:51 Added task 266592cd-960d-4091-981c-8c25c44b1018
{"status":"Pulling from strm/helloworld-http","id":"latest"}
{"status":"Digest: sha256:bd44b0ca80c26b5eba984bf498a9c3bab0eb1c59d30d8df3cb2c073937ee4e45"}
{"status":"Status: Image is up to date for strm/helloworld-http:latest"}
...
...
2024/09/07 19:42:28 Added task 266592cd-960d-4091-981c-8c25c44b1018 to stop container 611617ad1566e3e2dfc9266116d583852031947e0fa32c6e68373716b9533ea0
2024/09/07 19:42:33 Attempting to stop container: 611617ad1566e3e2dfc9266116d583852031947e0fa32c6e68373716b9533ea0
2024/09/07 19:42:43 Stopped and removed container 611617ad1566e3e2dfc9266116d583852031947e0fa32c6e68373716b9533ea0 for task 266592cd-960d-4091-981c-8c25c44b1018
2024/09/07 19:42:43 Sleeping for 10 secs.
```

## Part 3: Manager
この章では、Manager (Kubernetes でいう Control Plane) を実装していきます。

1. Manager 本体の実装
2. Manager の API 実装（ユーザのインターフェースとなる部分）
3. リカバリーの実装

といった流れで進んでいきます。

Worker と同様に Manager 本体の実装が終わると、つぎは、API server の実装です。

また、アプリケーションの不具合や、ハードウェアのリソース不足などオーケストレーションシステムにはリカバリー作業が付きものです。この章の最後では、Worker から渡されるタスク情報を基に health check やタスクリカバリーの実装を行います。

```sh
2024/09/15 17:26:30 Calling health check for task 21b23589-5d2d-4731-b5c9-a97e9832d021: /healthfail
2024/09/15 17:26:30 Calling health check for task 21b23589-5d2d-4731-b5c9-a97e9832d021: http://localhost:32771/healthfail
2024/09/15 17:26:30 Error health check for task 21b23589-5d2d-4731-b5c9-a97e9832d021 did not return 200 (actual: 500)

2024/09/15 17:26:30 Added task 21b23589-5d2d-4731-b5c9-a97e9832d021
2024/09/15 17:26:30 &task.Task{ID: ...}
```

## Part 4: Refactoring
この章では、
1. Scheduler
2. Persistent Datastore

の 2 つを実装します。

Scheduler では、`Scheduler interface` を作成しこれを Manager に渡すことで、多様なアルゴリズムの Scheduler を実装することができるようになります。この本では、Round-robin (これまでの章で実装してきたもの) と Epvm というアルゴリズムの実装をおこないます。

Persistent Datastore では、task や job を保存しておくことの重要性が説かれるとともに、前述の Scheduler と同様に interface を定義して、Replaceable な datastore を実装します。（built-in map, boltDB） の 2 パターンを実装します。

なお、自分は、Epvm, boltDB に関しては手をつけずスキップしました。


## Part 5: CLI
この章では、[Cobra](https://github.com/spf13/cobra) を用いて cube CLI の実装をしていきます。  
この章もスキップしたので詳しくは本を読んでください。

## 感想
4 章のスケジューラまで読めば基本的な動作をするオーケストレーターを作成することができます。  
なんとなく日常で使っている Kubernetes などのオーケストレーションシステムがどのように実装できるのかを手を動かしながらざっくりと理解するのに良い本だと思います。  

## 参考リンク
- [Build an Orchestrator in Go (From Scratch)](https://www.manning.com/books/build-an-orchestrator-in-go-from-scratch)
- [公式で提供されているソースコード](https://github.com/buildorchestratoringo)
- [自分の実装](https://github.com/granddaifuku/cube
)
