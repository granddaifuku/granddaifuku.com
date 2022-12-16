---
title: "GitLens for Emacs: Blamer.el"
author: ["Yudai Fukushima"]
date: 2022-12-16
lastmod: 2022-12-17
categories: ["Emacs"]
draft: false
description: "Emacs Blamer.el"
math: true
author:
  name: Yudai Fukushima
  image: /images/daifuku.webp
menu:
 sidebar:
   name: Emacs Blamer
   identifier: emacs-blamer
   parent: develop-jp
   weight: 10
---

この記事は [Emacs Advent Calendar 2022](https://qiita.com/advent-calendar/2022/emacs) 17日目の記事です。 <br/>


## はじめに {#はじめに}

VS Code を使ったことがある方なら誰しも一度は使用したことがあるであろうパッケージに [GitLens](https://gitlens.amod.io/) があります。 <br/>
これは、簡潔に言うとカーソルのある現在行や、クラスの先頭に Git Blame の情報を表示してくれるものです。 <br/>
以下に、VSCode での使用例を貼っておきます。 <br/>

{{< figure src="/files/emacs-blamer/vscode.webp" >}} <br/>

[Blamer.el](https://github.com/Artawower/blamer.el) は Artawower さんによって作成された Emacs 用の Git Blame プラグインです。 <br/>

> A git blame plugin for emacs inspired by VS Code’s GitLens plugin and Vim plugin <br/>

とあることからもわかるように、VSCode の GitLens や Vim の [Blamer.nvim](https://github.com/APZelos/blamer.nvim) プラグインと似た機能を持っています。 <br/>

日本語での記事が見当たらなかったため、この記事で軽く触れて行けたらと思っています。 <br/>


## 設定例 {#設定例}

最初に自分が使用している設定例を載せておきます。 <br/>

```emacs-lisp
(use-package blamer
  :ensure t
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 70)
  (blamer-pretty-time-p t)
  (blamer-author-formatter "✎ %s ")
  (blamer-datetime-formatter "[%s] ")
  (blamer-commit-formatter "● %s")
  (blamer-type 'visual)
  :config
  (global-blamer-mode 1))
```

実際の使用感は次のようになります。 <br/>

{{< figure src="/files/emacs-blamer/current.webp" >}} <br/>

カーソルのある行のコミット情報が表示されていることがわかると思います。 <br/>


## 説明 {#説明}

さらっと設定に触れていきます。 <br/>

-   Git Blame の情報を表示するまでにかかる秒数の設定 <br/>
    `(blamer-idle-time)` にて設定することができます。 <br/>

-   表示する際の著者・時刻・メッセージのフォーマットの設定 <br/>
    ```emacs-lisp
    (blamer-author-formatter "✎ %s ")    ;; 「✎ 著者名」と表示される
    (blamer-datetime-formatter "[%s] ")  ;; 「[コミット作成日時] 」と表示される
    (blamer-commit-formatter "● %s")     ;; 「● コミットメッセージ」 と表示される
    ```
    コミット作成者・作成日時・コミットメッセージの表示フォーマットを設定することができます。 <br/>
    さらに、コミット作成日時に関しては、 `(setq blamer-pretty-time-p t)` とすることでいい感じにしてくれます。 <br/>

-   コミット情報を表示するまでのオフセットの設定 <br/>
    `(blamer-min-offset)` にて設定することができます。 <br/>
    以下にオフセットを 10 に設定した場合の画像を貼っておきます。 <br/>
    
    {{< figure src="/files/emacs-blamer/offset-10.webp" >}} <br/>

-   コミット情報の表示方法の設定 <br/>
    `(blamer-type)` にて設定することができ、次の 5 パターンの表示方法があります。 <br/>
    
    1.  `selected` : マークされた各行に対してのコミット情報を表示します。 <br/>
        
        {{< figure src="/files/emacs-blamer/selected.webp" >}} <br/>
    
    2.  `visual` : カーソルがある現在行のコミット情報を表示します。 <br/>
        
        {{< figure src="/files/emacs-blamer/visual.webp" >}} <br/>
    
    3.  `both` : `selected` と `visual` 両方で情報を見ることが出来ます。 <br/>
    
    4.  `overlay-popup` : 名前の通りです。 `overlay-popup` の場合は、表示位置を上下選ぶことができます。 <br/>
    
    5.  `posframe-popup` : 同じく名前の通りです。 <br/>
    
    4, 5 に関しては、[公式から画像](https://github.com/Artawower/blamer.el/tree/master/images) が提供されています。 <br/>
    	  また、 `selected` の場合、 `blamer-max-lines` で表示する最大行数を設定することもできます。 <br/>

-   `blamer-show-commit-info` <br/>
    `M-x blamer-show-commit-info` でコミット情報を表示することができます。 <br/>
    
    {{< figure src="/files/emacs-blamer/show-commit-info.webp" >}} <br/>

他にも、 `uncommitted changes` の表示メッセージを変更できたり、コミット上にマウスを置いた際に、ツールチップを表示させたり等、もっと多くのことができます。 <br/>


## まとめ {#まとめ}

Emacs 用の GitLens パッケージ Blamer.el を紹介しました。 <br/>
メリークリスマス！ <br/>


## 参考リンク {#参考リンク}

-   [Artawower/blamer.el (GitHub)](https://github.com/Artawower/blamer.el) <br/>
-   [自分の設定ファイルへのリンク (GitHub)](https://github.com/granddaifuku/.emacs.d/blob/9a74af0a088d3d051ec78d61a93bb8c5124dc270/init.el#L635) <br/>

