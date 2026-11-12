# FanHub Archive 웹 링크 배포

이 프로젝트는 Flutter 웹 빌드를 사용하므로, 앱을 설치하지 않고 브라우저 링크로 열 수 있습니다. GitHub Pages 자동 배포 설정은 `.github/workflows/deploy-web.yml`에 포함되어 있습니다.

## 공개 링크 만들기 (GitHub Pages)

1. ZIP을 풀고, `pubspec.yaml`, `lib/`, `web/` 등이 들어 있는 프로젝트 폴더의 **내용물**을 GitHub 저장소의 최상위에 올립니다.
2. GitHub 저장소에서 **Settings → Pages → Build and deployment → Source**를 `GitHub Actions`로 설정합니다.
3. `main` 브랜치에 변경사항을 올리면 Actions가 Flutter 웹 빌드와 배포를 자동으로 진행합니다. `Actions` 탭에서 완료 여부를 확인하세요.
4. 배포가 끝나면 **Settings → Pages**에 표시되는 주소가 공유 링크입니다. 보통 `https://<계정이름>.github.io/<저장소이름>/` 형태입니다.

저장소 기본 브랜치가 `main`이 아니라면 `.github/workflows/deploy-web.yml`의 브랜치 이름을 저장소에 맞게 바꾸세요.

## 중요: 현재 데이터는 방문자끼리 공유되지 않습니다

Firebase 웹 설정이 없으면 앱은 데모 데이터와 브라우저 로컬 저장소로 실행됩니다. 따라서 한 방문자가 작성한 글·좋아요·프로필은 해당 브라우저에만 저장되고, 다른 방문자에게 보이지 않습니다. 방문자 간 데이터 공유와 계정 기능이 필요하면 Firebase 프로젝트를 만들고 웹 앱 설정 및 Firestore 보안 규칙을 별도로 구성해야 합니다.

## 로컬에서 직접 웹 빌드하기

Flutter SDK가 설치된 환경에서 프로젝트 폴더를 열고 다음을 실행합니다.

```bash
flutter pub get
flutter build web --release
```

완성된 정적 웹 파일은 `build/web/` 폴더에 생성되며, 이를 정적 웹 호스팅에 업로드하면 됩니다.
