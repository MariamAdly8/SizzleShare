'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "9cb3e55f9986f36f309e2932172cb736",
"assets/AssetManifest.bin.json": "a44f43353be7b097799e7697f9a271b1",
"assets/AssetManifest.json": "c305bb669e9c0829f3e8fef2dcf1ab54",
"assets/assets/images/almonds.png": "60a5861571b2fb5322d2129e5daae040",
"assets/assets/images/avatar1.jpg": "08d558eb6777e284781264340c47c896",
"assets/assets/images/avatar2.jpg": "a195a0f73f66153cc4fbea798b6ef226",
"assets/assets/images/avatar3.jpg": "a6d9237748ddb98c3af0d20b35a1ba16",
"assets/assets/images/avatar4.jpg": "ffbea87ad44f33da5856672d1de5a4e9",
"assets/assets/images/avatar5.jpg": "481ff9d4a4ac393685e49cc1ae5942f5",
"assets/assets/images/avatar6.jpg": "c6dc7276a283487160060f4ef737c7bb",
"assets/assets/images/banana.png": "cdeb973bc7b00541269135cab5feaf75",
"assets/assets/images/bg.png": "fd74aa32dc656b8216cb339134aa8f0d",
"assets/assets/images/breakfast.png": "c5cbe624042b36e220563287d52e94cc",
"assets/assets/images/burger.png": "9ea168b524b5d077d63626745ce1eb4b",
"assets/assets/images/Caesar_Salad.jpg": "7fa398ad3eabefb315b80edcd37ba08e",
"assets/assets/images/chicken.png": "9e1dbf749754951d8b901779af8305f1",
"assets/assets/images/croissant.png": "04397723d1646eeda248a83a94220885",
"assets/assets/images/desserts.png": "b6dadc8cd6c399070583222575b75871",
"assets/assets/images/eggs.png": "948e8c6db09bc4810b40ed85ef14981c",
"assets/assets/images/fish.png": "5ac1e2cafea5f6223e047cb64e4fd4ca",
"assets/assets/images/Fresh_Sushi.jpg": "8c7dad47ce1c57c74047938ca2407cf9",
"assets/assets/images/kiwi.png": "ab12f34ca5bf8fc32d1055ec59b1963f",
"assets/assets/images/meat.png": "3650c80febc78f24ef265dd708d0c367",
"assets/assets/images/milk.png": "f21860ab2e0c2b32aa6d8a9d409269e6",
"assets/assets/images/pancakes.jpg": "4c3fc5e05c8eb763f9072e3e34e6e117",
"assets/assets/images/peanuts.png": "4be56dba86c7316de38046a8f1b1ef15",
"assets/assets/images/pizza.png": "a27c5a284020873a790a941fe4b0beb3",
"assets/assets/images/quick_easy.png": "0356bf7690c0348113995a72af9fc641",
"assets/assets/images/rice.png": "dc3e0e4e7c242fd26bb1a28cbd80b6a3",
"assets/assets/images/salad.png": "4610d4dcd696679ce169b9934d5fe603",
"assets/assets/images/seafood.png": "3f13604c3c8cc57280413b135cabcd62",
"assets/assets/images/shellfish.png": "91f1eed0f4eaaa740393c66855880f73",
"assets/assets/images/shrimp.png": "9147ed0f9e7bc2f30f79dad0cba2e9b5",
"assets/assets/images/soup.png": "51701d0dc275c6694250256e41366110",
"assets/assets/images/splash.png": "d02c41ed744dcf895e6dc0ca48c7c2f6",
"assets/assets/images/sushi.png": "6a3fea97b8c407ddb9a659b9683ac6af",
"assets/assets/images/tiramisu.jpg": "25d43b07d11ff4dfa7ebfa4d783aa87e",
"assets/assets/images/treenuts.png": "a430cebc5ec59c77fcb58c7a20f5d3ee",
"assets/assets/images/wheat.png": "cf01c62ec278b246b9733dc5eac72b3b",
"assets/assets/logo/logo.png": "f0866665e5f4829dbba5619065f7470b",
"assets/assets/sounds/splash_sound.mp3": "54af6ddcc8d2712ab700cc7578a62cd1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "aecaf1a82c4ee10ed165f8143422442c",
"assets/NOTICES": "790b912f82bed3e38c9f86f7680d592c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "c5fff1da44a699de414f44d3268dfd58",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "bf07c1b3b510b44496162b1e4e4fdd6d",
"/": "bf07c1b3b510b44496162b1e4e4fdd6d",
"main.dart.js": "bbf7e5586071a56febcfda7831b953d9",
"manifest.json": "286c340f4510416e6ca23a95179918a8",
"version.json": "ec1598f310c0010af13ff10b10e58918"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
