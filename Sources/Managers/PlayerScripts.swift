import Foundation

enum PlayerScripts {
    static let scrollbarStyle: String = """
    (function() {
        function injectStyles() {
            if (document.getElementById('ytmusic-scrollbar-style')) return;
            const style = document.createElement('style');
            style.id = 'ytmusic-scrollbar-style';
            style.textContent = `
                html {
                    color-scheme: dark !important;
                    background-color: #0f0f0f !important;
                }
                ::-webkit-scrollbar {
                    width: 10px !important;
                    height: 10px !important;
                    background-color: #0f0f0f !important;
                }
                ::-webkit-scrollbar-track {
                    background: #0f0f0f !important;
                }
                ::-webkit-scrollbar-thumb {
                    background: #333 !important;
                    border-radius: 5px !important;
                    border: 2px solid #0f0f0f !important;
                }
                ::-webkit-scrollbar-thumb:hover {
                    background: #555 !important;
                }
                ::-webkit-scrollbar-corner {
                    background-color: #0f0f0f !important;
                }
            `;
            (document.head || document.documentElement).appendChild(style);
        }

        injectStyles();
        // head의 직접 자식만 감시 — subtree 감시는 SPA에서 성능 부담이 큼
        const target = document.head || document.documentElement;
        const observer = new MutationObserver(injectStyles);
        observer.observe(target, { childList: true });
    })();
    """

    static let playerObserver: String = #"""
    (function() {
        if (window.location.hostname !== 'music.youtube.com') return;

        function observePlayer() {
            const playerBar = document.querySelector('ytmusic-player-bar');
            if (!playerBar) { setTimeout(observePlayer, 1000); return; }
            function updateStatus() {
                try {
                    const title = document.querySelector('.title.style-scope.ytmusic-player-bar')?.innerText || "";
                    const artist = document.querySelector('.byline.style-scope.ytmusic-player-bar')?.innerText || "";
                    const artEl = document.querySelector('#layout > ytmusic-player-bar > div.middle-controls.style-scope.ytmusic-player-bar > img')
                        || document.querySelector('ytmusic-player-bar img#thumbnail')
                        || document.querySelector('ytmusic-player-bar img');
                    const rawSrc = artEl?.src || "";
                    const art = rawSrc.replace(/=w\d+-h\d+[^"]*$/, '=w200-h200-l90-rj');
                    window.webkit.messageHandlers.trackChanged.postMessage({title, artist, art});
                } catch(e) {}
            }
            let _t;
            const observer = new MutationObserver(() => { clearTimeout(_t); _t = setTimeout(updateStatus, 100); });
            observer.observe(playerBar, { childList: true, subtree: true, attributes: true, attributeFilter: ['aria-label', 'src'] });
            window.addEventListener('pagehide', () => { observer.disconnect(); clearTimeout(_t); }, { once: true });
            updateStatus();
        }

        function observePlayback() {
            const video = document.querySelector('video');
            if (!video) { setTimeout(observePlayback, 1000); return; }
            function sendPlayback() {
                try {
                    window.webkit.messageHandlers.playbackChanged.postMessage(!video.paused);
                } catch(e) {}
            }
            function sendProgress() {
                try {
                    const currentTime = isFinite(video.currentTime) ? video.currentTime : 0;
                    const duration = isFinite(video.duration) ? video.duration : 0;
                    window.webkit.messageHandlers.progressChanged.postMessage({currentTime, duration});
                } catch(e) {}
            }
            video.addEventListener('play', sendPlayback);
            video.addEventListener('pause', sendPlayback);
            video.addEventListener('timeupdate', sendProgress);
            video.addEventListener('durationchange', sendProgress);
            window.addEventListener('pagehide', () => {
                video.removeEventListener('play', sendPlayback);
                video.removeEventListener('pause', sendPlayback);
                video.removeEventListener('timeupdate', sendProgress);
                video.removeEventListener('durationchange', sendProgress);
            }, { once: true });
            sendPlayback();
            sendProgress();
        }

        function observeRepeat() {
            const playerBar = document.querySelector('ytmusic-player-bar');
            if (!playerBar) { setTimeout(observeRepeat, 1000); return; }
            let lastRepeatMode = null;
            function sendRepeat() {
                try {
                    const btn = Array.from(playerBar.querySelectorAll('button')).find(b =>
                        (b.getAttribute('aria-label') || '').includes('반복') ||
                        (b.getAttribute('aria-label') || '').toLowerCase().includes('repeat'));
                    if (!btn) return;
                    const label = btn.getAttribute('aria-label') || '';
                    let mode = 'off';
                    if (label === '1개 반복' || label.toLowerCase().includes('one')) {
                        mode = 'one';
                    } else if (label === '모두 반복' || (label.includes('반복') && label !== '반복 사용 안함')) {
                        mode = 'all';
                    }
                    if (mode === lastRepeatMode) return;
                    lastRepeatMode = mode;
                    window.webkit.messageHandlers.repeatChanged.postMessage(mode);
                } catch(e) {}
            }
            const obs = new MutationObserver(sendRepeat);
            obs.observe(playerBar, { subtree: true, attributes: true, attributeFilter: ['aria-label'] });
            window.addEventListener('pagehide', () => obs.disconnect(), { once: true });
            sendRepeat();
        }

        function observeShuffle() {
            const playerBar = document.querySelector('ytmusic-player-bar');
            if (!playerBar) { setTimeout(observeShuffle, 1000); return; }
            let lastShuffleActive = null;
            function getShuffleIcon() {
                const btn = Array.from(playerBar.querySelectorAll('button')).find(b =>
                    (b.getAttribute('aria-label') || '').includes('셔플') ||
                    (b.getAttribute('aria-label') || '').toLowerCase().includes('shuffle')
                );
                if (!btn) return null;
                return btn.querySelector('yt-icon') || btn.querySelector('svg') || btn;
            }
            function sendShuffle() {
                try {
                    const icon = getShuffleIcon();
                    if (!icon) return;
                    const active = window.getComputedStyle(icon).color === 'rgb(255, 255, 255)';
                    if (active === lastShuffleActive) return;
                    lastShuffleActive = active;
                    window.webkit.messageHandlers.shuffleChanged.postMessage(active);
                } catch(e) {}
            }
            const obs = new MutationObserver(sendShuffle);
            obs.observe(playerBar, { subtree: true, attributes: true, attributeFilter: ['style', 'class'] });
            window.addEventListener('pagehide', () => obs.disconnect(), { once: true });
            setTimeout(sendShuffle, 500);
        }

        observePlayer();
        observePlayback();
        observeRepeat();
        observeShuffle();
    })();
    """#
}
