// Firebase Cloud Messaging service worker for Flutter Web.
// IMPORTANT: replace the firebaseConfig values below with the Web app config from
// Firebase console > Project settings > Your apps > Web. The service worker can
// not import firebase_options.dart, so the values must be hard-coded here.

importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'REPLACE_ME',
  authDomain: 'REPLACE_ME.firebaseapp.com',
  projectId: 'REPLACE_ME',
  storageBucket: 'REPLACE_ME.appspot.com',
  messagingSenderId: 'REPLACE_ME',
  appId: 'REPLACE_ME',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  self.registration.showNotification(notification.title || 'Bantay Barangay Alert', {
    body: notification.body || '',
    icon: notification.icon || '/icons/Icon-192.png',
    data: payload.data || {},
  });
});
