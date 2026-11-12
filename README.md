# FanHub Archive

Flutter 기반 팬덤 아카이브 앱입니다. 브라우저에서 링크로 열 수 있도록 웹 메타데이터와 GitHub Pages 자동 배포 설정을 포함했습니다.

## 웹 링크 배포

`WEB_DEPLOY.md`의 안내를 따라 GitHub Pages를 설정하세요. `main` 브랜치에 올리면 GitHub Actions가 웹 빌드와 배포를 진행합니다.

## 로컬 웹 빌드

```bash
flutter pub get
flutter build web --release
```

빌드 결과물은 `build/web/`에 생성됩니다.

## 데이터 저장 안내

Firebase 웹 설정이 없으면 데모 모드로 실행됩니다. 사용자별 데이터는 각 브라우저에만 저장되며 방문자끼리 공유되지 않습니다. 여러 방문자가 같은 데이터를 보거나 계정을 사용하려면 Firebase 설정과 보안 규칙이 추가로 필요합니다.
