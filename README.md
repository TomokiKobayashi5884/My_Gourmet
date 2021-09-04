# My Gourmet
---
## アプリケーション概要
ユーザー同士がグルメ写真を投稿し合うことで、お互いのおすすめのグルメ情報を共有できるSNSアプリです。  
投稿の♡食べたい！ボタン（いいね！のようなもの）を押すだけで、簡単に自分だけの食べたい物リストを作成することができます。  
(※レスポンシブ対応となっているため、PC、iPad、スマホからも使用可能となっております。）

## URL  
https://mygourmet2021.herokuapp.com  (heroku)  
                 ↓　移行しました  
https://mygourmet2021.com  (AWS EC2)  

※ ゲストとしてログインする場合  
メールアドレス : guestuser@example.com  
パスワード : guest2021

## 作成した目的
3点あります。
- グルメ好きな人がまだ知らないグルメに簡単に出会える場を作りたかった。
- 簡単に食べたい物リストを作れるアプリを作りたかった。
- コロナ禍で経営が大変な飲食店の力になりたかった。  
My Gourmetを使用するユーザーが増えることでユーザーがより多くのグルメに出会うことができるようになるだけでなく、飲食店の集客にも繋がると考え、作成しました。   


## 機能一覧

- 会員登録機能、ログイン機能 [devise]　　
- ユーザー情報編集機能　　
- 退会機能　　
- 投稿機能  
  - 画像投稿機能 [CarrierWave]  
  - 画像加工機能 [mini_magick]  
  - 画像プレビュー機能  
  - 店舗情報検索機能 [ホットペッパーAPI、Ajax]  
  - 店舗情報自動入力機能 [Ajax]  
- 投稿一覧機能  
  - 投稿検索機能 （キーワード、都道府県、エリア、ジャンルの複数条件対応）  
  - 食べたい数ランキング機能  
  - ページネーション機能 [kaminari]
  - ホットペッパーグルメ公式サイトでの検索機能  
- 投稿詳細機能  
  - コメント機能  
    - コメント削除機能 （※ 自分がしたコメントのみ）  
- 過去の投稿一覧機能（自分の投稿）  
- 投稿編集機能  
- 投稿削除機能  
- 食べたい機能 (Ajax)  
  - 食べたい数表示機能  
- 食べたい物リスト一覧機能 (自分の食べたい一覧）  
  - リスト内検索 （キーワード、都道府県、エリア、ジャンルの複数条件対応）  
- お問い合わせ機能
  - お問い合わせ内容確認機能
- レスポンシブ対応 (ハンバーガーメニュー等)
 

## 使用方法
My Gourmetでは大きく分けて3つのことができます。  
- ### 他のユーザーにグルメをオススメする  
  1.　画面上部にある＋新規投稿ボタンから新規投稿フォームへ移動  
  2.　フォーム内のオススメ？ or 食べたい?欄にて、オススメ！を選択し、グルメ記事を投稿してください。  
     ![ate3](https://user-images.githubusercontent.com/82651310/127872329-fff1e9f9-9eb7-40b1-92f6-be0839fd0d02.gif)

     (※ 投稿時、店舗情報も一緒に登録することで、投稿閲覧時に店舗情報も表示されます。）  
     (※ ホットペッパーグルメに掲載されているお店であれば、フォーム内から検索することができます。)  
     ![店舗情報入力](https://user-images.githubusercontent.com/82651310/127951248-71ae0a04-a279-4dfd-b954-21379d290c21.gif)

- ### 食べたい物を探す  
  1.　投稿一覧画面にある投稿検索フォームにてお好みの条件を入力し、検索してください。  
     (※ キーワード、都道府県、エリア、ジャンルごとに検索できます。)  
  2.　気になる投稿があればクリックすることで、店舗情報などの情報を見ることができます。
     ![投稿検索](https://user-images.githubusercontent.com/82651310/127951945-8a2f3b27-f0de-4523-8c26-84b69b2e9d02.gif)

  3.　投稿に関する詳細な情報を知りたい場合はコメントすることもできます。 
- ### 食べたい物リストを作成する  
  1.　投稿一覧、または投稿詳細画面にある♡を押すと、その投稿が食べたい物リストに追加されます。  
  (※ ♡をもう一度押すと、リストから削除されます。）  
     ![食べたい！](https://user-images.githubusercontent.com/82651310/127954264-6ef54fef-fad9-4167-ac2a-d61e09271792.gif)
     
     (※ 投稿されているグルメ以外に食べたい物がある場合は、そのグルメに関する投稿をしてください。  
     新規投稿時にオススメ？ or 食べたい?欄にて、食べたい！を選択することで自動的にリストに追加されます。)  
     ![食べたい！（新規投稿）](https://user-images.githubusercontent.com/82651310/127954609-ca508fb6-5b16-4212-ba45-b10e1f890505.gif)
     
  2.　画面上部、またはマイページ内の♡食べたい物リストボタンから、リストに登録したグルメ記事を見ることができます。   
     ![食べたい！2](https://user-images.githubusercontent.com/82651310/127955363-58ccbbb5-65fb-46bb-b233-c2f025e4702e.gif)

## 使用技術  
- ### 言語
  - Ruby 2.6.5
- ### フレームワーク
  - Ruby on Rails 5.2.4.2 
- ### 外部API
  - ホットペッパーAPI
- ### インフラ構成図
![My Gourmetのインフラ図](https://user-images.githubusercontent.com/82651310/130798559-04b6ceb9-ac8c-4bdc-b80f-7943e0e91de8.png)

- ### AWS
  - VPC
  - EC2
  - RDS
  - Route53
  - ALB
  - ACM
  - S3
  - CloudFront
- ### Webサーバー
  - Nginx 1.20.0
- ### データベース
  - MySQL 8.0 (RDS)

## 今後の予定
- Dockerの導入
