importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
    // These values should ideally come from your Firebase project configuration
    // For basic service worker registration, it might just need the messaging sender id
    // but usually it's better to provide the whole config.
    // We'll leave it minimal for now to fix the registration error.
    apiKey: "TODO_REPLACE_WITH_YOUR_API_KEY",
    authDomain: "watchhub-app-c8e1a.firebaseapp.com",
    projectId: "watchhub-app-c8e1a",
    storageBucket: "watchhub-app-c8e1a.appspot.com",
    messagingSenderId: "495177119332",
    appId: "1:495177119332:web:968f7f017415d852934149"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/firebase-logo.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
