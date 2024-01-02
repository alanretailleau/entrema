'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "c2a1934ef3d8eeea61e201e584205cb4",
"index.html": "1f9a70bcb3af1af2a278bd3a08d5220a",
"/": "1f9a70bcb3af1af2a278bd3a08d5220a",
"main.dart.js": "c2a1299a2715fee7f83b5db829286517",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "af854f8fbb97bc460ed90ee5aaa98013",
"assets/AssetManifest.json": "3e440620aeab9db2265d98ce0ddba046",
"assets/NOTICES": "a50c441a8cd64b0f95ec4963d8e5abbb",
"assets/FontManifest.json": "c2fb432646b6575b9cd59935d5c9ffeb",
"assets/AssetManifest.bin.json": "fc677b0c047c4f4a60706e9718ca8e5f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/AssetManifest.bin": "c00280d0743f909d1e6832754ee3429a",
"assets/fonts/CocoSharpS-Bold.otf": "9504c40793fb068f5fa0ae2b8baab430",
"assets/fonts/CocoSharpS-LightItalic.otf": "6d982a7879baaf95b200a723c2e7ccff",
"assets/fonts/CocoSharpS-ExtralightItalic.otf": "13121a70bf14f4000a49645616966004",
"assets/fonts/CocoSharpS-HeavyItalic.otf": "05dd399c7e75c6edb61aae1a5bce22e1",
"assets/fonts/CocoSharpS-Italic.otf": "c0b750802a7ca3b068e4c0f9bfa33da4",
"assets/fonts/CocoSharpS-Extralight.otf": "4a26a7dc30595d2ee5a0ad79bd79a216",
"assets/fonts/CocoSharpS-BoldItalic.otf": "5d2ac6d08614b733d64e21f99f46723f",
"assets/fonts/CocoSharpS-Heavy.otf": "43cc327f93dcfdb89beac9da616c02e1",
"assets/fonts/CocoSharpS-ExtraBoldItalic.otf": "ab39b1b9deadbe68f165dab2fad52612",
"assets/fonts/CocoSharpS-ExtraBold.otf": "a22db2b37ed053999cfd6e01a28cd57e",
"assets/fonts/CocoSharpS-Regular.otf": "1e544f730a50202884c871a93558fb4a",
"assets/fonts/MaterialIcons-Regular.otf": "d0073a9434bad33300e54fdad68213e1",
"assets/fonts/CocoSharpS-Light.otf": "4f72970a674f981d63694af629573d7c",
"assets/assets/icon.png": "1952813c179c23b0ae6cc2cceeb4a408",
"assets/assets/icon/info.png": "ffd4d41a020b4c8c54f77a017936bc9b",
"assets/assets/icon/add.png": "3a9b5cec78681c4968e432d0b4470189",
"assets/assets/icon/receive.png": "2d18a170403a2c5bac77162b129a26b5",
"assets/assets/icon/hierarchie.png": "1341cbbefe8f5ebbc1de8162a2a943a6",
"assets/assets/icon/event.png": "f20de2ead852b33d66877fa1e9f2d437",
"assets/assets/icon/categorie.png": "f9d80be384864ff7f3f7f76b55ea8ac9",
"assets/assets/icon/echange.png": "8889e8bdf25c13b29332379532b1eac2",
"assets/assets/icon/place.png": "d68fa285f978b91bc05068ce6cc8be65",
"assets/assets/icon/discover.png": "ec979b0f9f2ce26a0a0ba0f97b8a2580",
"assets/assets/icon/time.png": "651b44b206c03d10952bd087b3d8e09b",
"assets/assets/icon/download.png": "2681adf94ed6b93dd227102a11b706a5",
"assets/assets/icon/localisation.png": "e0e778ab6fdded9b28dd4f8efb4ae53d",
"assets/assets/icon/add-camera.png": "5d4b535ec45ffa00ccc5ee3908185c1c",
"assets/assets/icon/settings.png": "6ec8f3ffe4abff7adf7cf51a0ef1d2b2",
"assets/assets/icon/subscribe.png": "c146345e17a8105ab1b7ef4c422fb114",
"assets/assets/icon/historique.png": "abfcd6dee89c8d415ecbece1a7e46064",
"assets/assets/icon/product.png": "35e0ee80b9d0c97fbde9e600862819c5",
"assets/assets/icon/link.png": "90ddf616201f1d70b754defa7cd789cf",
"assets/assets/icon/carrousel.png": "ec39500284ab96af6c4966afcbb1d56e",
"assets/assets/icon/settings2.png": "150b788a6201ddf6cc705dcaf9ff6a6e",
"assets/assets/icon/drawer.png": "a8c43aaf07b98bdddc8adf855daa3109",
"assets/assets/icon/visible.png": "312b51fdaa7d844e5961543f8bde27e5",
"assets/assets/icon/speed.png": "47de1d5e28215a7f2ab502c18dfe9eed",
"assets/assets/icon/sondage.png": "cc7c2c981a58d29d7fbfe0ba0fd3ddb0",
"assets/assets/icon/file.png": "b81493ecfc9e6df734c97ee16098550a",
"assets/assets/icon/verified.png": "00c81968904704eaa5eb816d91475c9f",
"assets/assets/icon/urgence.png": "19c0b1dd634ebfcbff927f30f6e8aa37",
"assets/assets/icon/animation.png": "7143b9d9743064fbbaeee3ba676b3bc7",
"assets/assets/icon/cancel.png": "c9f34712c33ca6673b5d4e557dd200ee",
"assets/assets/icon/boutique.png": "4b155f1ed0b76a55820a5dd8c6ae400d",
"assets/assets/icon/arbre.png": "21eecda49561c0e6d9ac101a11eae853",
"assets/assets/icon/cadeau.png": "5d40cca756f10fca6b9f8d2029902b96",
"assets/assets/icon/home.png": "df897f426f21754bfeb7cdbdefd2006e",
"assets/assets/icon/retrait.png": "4724dc188923ec42d7b567a7ca44d4b1",
"assets/assets/icon/transparent_image.png": "7b9ba36a85f89b1b79801f3d25a02b39",
"assets/assets/icon/arrow.png": "b8802797e770c0044509ee4e4c01b798",
"assets/assets/icon/universe.png": "55166ea7310f0faa628b57bcfa5c8842",
"assets/assets/icon/reply.png": "0e04dfef47ed71a5a96515f6f432df89",
"assets/assets/icon/fingerprint2.png": "2404c074ff6303d2d4d5bda837851ddc",
"assets/assets/icon/equipe.png": "d6f1c4f72e662664058075128029de41",
"assets/assets/icon/search.png": "e3f022fbb37c2a34d7d6cccdb97500e6",
"assets/assets/icon/row.png": "130433c0e59d3ace48689f0bbb4d40ae",
"assets/assets/icon/stats.png": "3209c370d7ce617ef3666a36380dc563",
"assets/assets/icon/stat2.png": "cc7c2c981a58d29d7fbfe0ba0fd3ddb0",
"assets/assets/icon/invisible.png": "3fd2f7efed343744ebbcaa03cc556b00",
"assets/assets/icon/add2.png": "77a877ab6d6c0b8c74636831919d6736",
"assets/assets/icon/calendar.png": "9800b12702ec3013303e76e64767a50b",
"assets/assets/icon/reservation.png": "9800b12702ec3013303e76e64767a50b",
"assets/assets/icon/video.png": "a5e4971b9c719f9998c62b31cb702a03",
"assets/assets/icon/remove.png": "5fd6ae807e23973b6135b7b005c9f9a3",
"assets/assets/icon/profile.png": "1b10c64c22784d8751057c34b0809cc5",
"assets/assets/icon/web.png": "13bcf9a2b5256cbb1167532cb10118b7",
"assets/assets/icon/bin.png": "37629e8b0be1a092a5a413c9a15eb09e",
"assets/assets/icon/settingsUser.png": "2a32b33de5214ce5df468ca802d88ce0",
"assets/assets/icon/calendar2.png": "030b6f93828559e783b2ee28c9c37d02",
"assets/assets/icon/annonce.png": "758bc60124c62dbea3604174de971ef5",
"assets/assets/icon/treso.png": "cf728ed6cbc66286db195a7e7709ab49",
"assets/assets/icon/unsubscribe.png": "eb3a036ac5926fd98a4ac8c220d4e07f",
"assets/assets/icon/idea.png": "14b759bc8aca0294a40ce7aa97c561b7",
"assets/assets/icon/abonnement.png": "4ea02d2c946a09518de9c444c7c032a8",
"assets/assets/icon/edit.png": "e658f9845ba57cb26b29243615fda96b",
"assets/assets/icon/page.png": "a0de2118d4a3e5979afe406334a0b8c5",
"assets/assets/icon/star.png": "21d60fab6190b1de30e731b1568cbe79",
"assets/assets/icon/piece.png": "843a8d5a37e503281054a15c9c89e78a",
"assets/assets/icon/coeur.png": "114db5a28c3c30bba28719f48919a50c",
"assets/assets/icon/bouton.png": "2333cf6853402a61baefaf1718bbd9f9",
"assets/assets/icon/notification.png": "203b8dbc49006f380d8698321ed66ecc",
"assets/assets/icon/chat.png": "3d148bfc0b1681fca4d5c18fde800473",
"assets/assets/icon/send.png": "592bf5fd0b09308760111cb10fc52171",
"assets/assets/icon/LE%2520BUREAU.png": "f53300d1f80e4ddfaf2344a4655b6598",
"assets/assets/icon/play.png": "a49228c0b1ca8ab89ef89a17e7ffd156",
"assets/assets/icon/badge.png": "a13b9ed32ca525fc1f58ea9332039b76",
"assets/assets/icon/setting.png": "150b788a6201ddf6cc705dcaf9ff6a6e",
"assets/assets/icon/back.png": "92ca0b396cc80fad2dda089a832aa0c7",
"assets/assets/icon/scan.png": "c5cf31ec1017bd2ed6859353d521151b",
"assets/assets/icon/smile.png": "bee2e271808e6ae8264799e35ab48516",
"assets/assets/icon/text.png": "83cef738b504ad158b74924b43f4fd8d",
"assets/assets/icon/refresh.png": "705cca1975d4341b5f6f4ca0554bb4bd",
"assets/assets/icon/image.png": "96d0bb27867cde98b248f731ead67c01",
"assets/assets/icon/play2.png": "470b277efd1c4852007c0f278d2a3743",
"assets/assets/icon/copy.png": "390ef98aa8a28f6fe0892de28c43ec1b",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
