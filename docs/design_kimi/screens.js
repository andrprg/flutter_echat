/* ==========================================================================
   E-Chat · Tablet & Desktop mockups — рендер экранов
   Каждый экран — функция render(ff), ff = 'tablet' | 'desktop'.
   Тема применяется через data-theme на .frame (см. tokens.css).
   Тексты UI — на английском (язык оригинального Figma-кита);
   форма авторизации — на русском (целевая локаль приложения).
   ========================================================================== */

/* ---------------------------------------------------------------- Иконки */
/* Material/Feather-подобные outlines, 24×24, stroke — как глифы кита */
const ICONS = {
  chat: '<path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>',
  group: '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
  user: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  grid: '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/>',
  search: '<circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  phone: '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z"/>',
  phoneDown: '<g transform="rotate(135 12 12)"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.79 19.79 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.91.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z"/></g>',
  video: '<path d="M23 7l-7 5 7 5V7z"/><rect x="1" y="5" width="15" height="14" rx="2"/>',
  info: '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>',
  mic: '<path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><path d="M12 19v4M8 23h8"/>',
  micOff: '<path d="M2 2l20 20"/><path d="M9 9v3a3 3 0 0 0 5.12 2.12M15 9.34V4a3 3 0 0 0-5.94-.6"/><path d="M17 16.95A7 7 0 0 1 5 12v-2m14 0v2a7 7 0 0 1-.11 1.23"/><path d="M12 19v4M8 23h8"/>',
  send: '<path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4 20-7z"/>',
  smile: '<circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><path d="M9 9h.01M15 9h.01"/>',
  x: '<path d="M18 6L6 18M6 6l12 12"/>',
  checks: '<path d="M1.5 13l3.5 3.5L12.5 9"/><path d="M9.5 16l2 2L22 7.5"/>',
  download: '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="M7 10l5 5 5-5"/><path d="M12 15V3"/>',
  zap: '<path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/>',
  flip: '<path d="M23 4v6h-6"/><path d="M1 20v-6h6"/><path d="M3.5 9a9 9 0 0 1 14.85-3.36L23 10"/><path d="M1 14l4.64 4.36A9 9 0 0 0 20.5 15"/>',
  camera: '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>',
  sun: '<circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/>',
  moon: '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>',
  dotsV: '<circle cx="12" cy="5" r="1.6"/><circle cx="12" cy="12" r="1.6"/><circle cx="12" cy="19" r="1.6"/>',
  pencil: '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>',
  bell: '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>',
  shield: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
  database: '<ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/>',
  userPlus: '<path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><path d="M20 8v6M23 11h-6"/>',
  help: '<circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><path d="M12 17h.01"/>',
  file: '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M16 13H8M16 17H8M10 9H8"/>',
  star: '<path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>',
  logout: '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/>',
  chevR: '<path d="M9 18l6-6-6-6"/>',
  lock: '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
  mail: '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 6l-10 7L2 6"/>',
  speaker: '<path d="M11 5L6 9H2v6h4l5 4V5z"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/>',
};

/** svg-обёртка для глифа */
function ic(name, size = 24) {
  return `<svg class="ic" width="${size}" height="${size}" viewBox="0 0 24 24">${ICONS[name]}</svg>`;
}

/* ---------------------------------------------------------------- Логотип */
/* Файлы бренда из assets/logos: знак (174×158) и знак + wordmark (465×158).
   Версия под тему переключается классами logo-l / logo-d (см. tokens.css). */
const LOGO_DIR = '../../assets/logos';

/** Знак логотипа без подписи — rail, empty-state */
function logoMark(size) {
  const h = Math.round(size * 158 / 174);
  return `<img class="logo-img logo-l" src="${LOGO_DIR}/logo_light.png" width="${size}" height="${h}" alt="E-Chat" />`
    + `<img class="logo-img logo-d" src="${LOGO_DIR}/logo_dark.png" width="${size}" height="${h}" alt="E-Chat" />`;
}

/** Логотип с подписью E-CHAT; forceDark — на цветных панелях (фон всегда тёмный) */
function logoFull(height, forceDark = false) {
  const w = Math.round(height * 465 / 158);
  if (forceDark) return `<img class="logo-img" src="${LOGO_DIR}/logo_echat_dark.png" width="${w}" height="${height}" alt="E-Chat" />`;
  return `<img class="logo-img logo-l" src="${LOGO_DIR}/logo_echat_light.png" width="${w}" height="${height}" alt="E-Chat" />`
    + `<img class="logo-img logo-d" src="${LOGO_DIR}/logo_echat_dark.png" width="${w}" height="${height}" alt="E-Chat" />`;
}

/* ---------------------------------------------------------------- Аватары */
/* Градиентные плейсхолдеры с инициалами — как градиентные аватары кита */
const AV_GRADS = [
  ['#1565C0', '#0F4888'], ['#40C4FF', '#0288D1'], ['#FF8A65', '#F4511E'],
  ['#BA68C8', '#8E24AA'], ['#13C296', '#0A8F6C'], ['#F06292', '#C2185B'],
];
function avHash(s) { let h = 0; for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0; return h; }

function av(name, size = 48, opts = {}) {
  const initials = name.split(' ').map(w => w[0]).slice(0, 2).join('').toUpperCase();
  const [c1, c2] = opts.grad || AV_GRADS[avHash(name) % AV_GRADS.length];
  const dot = opts.online ? '<span class="dot"></span>' : '';
  return `<div class="av" style="width:${size}px;height:${size}px;font-size:${Math.round(size * 0.36)}px;background:linear-gradient(135deg,${c1},${c2})">${initials}${dot}</div>`;
}

/* ---------------------------------------------------------------- Данные */
const CHATS = [
  { n: 'Anneliese', m: 'Hello, Good Morning...', t: '09:46', b: 2, on: true },
  { n: 'Danielle', m: 'OMG 😱 OMG...', t: '08:15', read: true },
  { n: 'Maxwell Williamson', m: 'Thank You 🙏', t: '07:30', b: 2, on: true },
  { n: 'Theresa', m: 'Hi, Morning too!', t: '06:12' },
  { n: 'Marvin', m: 'See you tomorrow!', t: '04:30', read: true },
  { n: 'Courtney', m: 'Cool! 👍', t: '03:28', on: true },
  { n: 'Floyd', m: '🎙 Voice message · 0:24', t: '01:07' },
  { n: 'Cody', m: '📷 Photo', t: 'Yesterday', b: 5 },
  { n: 'Jerome Bell', m: 'Perfect, thanks!', t: 'Yesterday', read: true },
  { n: 'Annette', m: "Let's catch up soon", t: 'Monday' },
];
const STORIES = ['Anneliese', 'Danielle', 'Theresa', 'Marvin', 'Floyd'];

/* ---------------------------------------------------------------- Хелперы */

/** Навигационный chrome: rail 72 (tablet portrait) / sidebar 240 (desktop и tablet landscape — ширина 1024 ≥ брейкпоинта 1024) */
function chrome(active, ff) {
  const dests = [
    { id: 'chats', icon: 'chat', label: 'Chats' },
    { id: 'groups', icon: 'group', label: 'Groups' },
    { id: 'profile', icon: 'user', label: 'Profile' },
    { id: 'more', icon: 'grid', label: 'More' },
  ];
  if (ff === 'tablet') {
    return `<nav class="rail">
      ${logoMark(40)}
      ${dests.map(d => `<button class="dest ${d.id === active ? 'active' : ''}" title="${d.label}">${ic(d.icon, 24)}</button>`).join('')}
      <div class="spacer"></div>
      ${av('John Doe', 40)}
    </nav>`;
  }
  return `<nav class="sidebar">
    <div class="brand">${logoFull(34)}</div>
    ${dests.map(d => `<button class="dest ${d.id === active ? 'active' : ''}">${ic(d.icon, 22)}<span class="lbl">${d.label}</span>${d.id === 'chats' ? '<span class="badge">9</span>' : ''}</button>`).join('')}
    <div class="spacer"></div>
    <button class="dest">${ic('moon', 22)}<span class="lbl">Dark Mode</span></button>
    <div style="display:flex;align-items:center;gap:12px;padding:10px 12px;border-top:1px solid var(--divider);margin-top:4px">
      ${av('John Doe', 40)}
      <div style="min-width:0"><div style="font-weight:600;font-size:14px">MR. John Doe</div>
      <div style="font-size:12px;color:var(--on-variant)">+62 857-4852-1265</div></div>
    </div>
  </nav>`;
}

/** Тайл диалога — 64 dp, density tablet/desktop */
function tile(c, selected) {
  const right = c.b
    ? `<span class="badge">${c.b}</span>`
    : (c.read ? `<span class="ticks">${ic('checks', 16)}</span>` : '');
  return `<div class="tile ${selected ? 'selected' : ''}">
    ${av(c.n, 48, { online: c.on })}
    <div class="tt">
      <div class="nm"><span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${c.n}</span><time>${c.t}</time></div>
      <div class="pv"><span>${c.m}</span>${right}</div>
    </div>
  </div>`;
}

/** Master — колонка списка чатов (300 / 320) */
function master(selectedName) {
  return `<section class="master">
    <div class="master-head">
      <div class="searchbox">${ic('search', 18)}<input placeholder="Search" /></div>
      <button class="btn-circle grad-light-blue">${ic('plus', 20)}</button>
    </div>
    <div class="stories">
      <div class="story add"><div class="ring">${ic('plus', 18)}<span class="plus-badge">${ic('plus', 10)}</span></div><span class="nm">You</span></div>
      ${STORIES.map(s => `<div class="story"><div class="ring">${av(s, 48)}</div><span class="nm">${s}</span></div>`).join('')}
    </div>
    <div class="tabs">
      <button class="tab active">Chats</button><button class="tab">Groups</button>
      <button class="tab">Status</button><button class="tab">Calls</button>
    </div>
    <div class="tiles scroll-thin">${CHATS.map(c => tile(c, c.n === selectedName)).join('')}</div>
  </section>`;
}

/** Пузырь сообщения */
function msg(dir, text, time, opts = {}) {
  const sender = opts.sender ? `<div class="sender" style="color:${opts.senderColor}">${opts.sender}</div>` : '';
  const doc = opts.doc ? `<div class="doc-card"><div class="di">${ic('download', 18)}</div><div><div class="dn">${opts.doc}</div><div class="ds">${opts.docSize}</div></div></div>` : '';
  const ticks = dir === 'out' ? ic('checks', 14) : '';
  const avatarHtml = opts.avatar ? av(opts.avatar, 28) : '';
  return `<div class="msg-row ${dir}">${avatarHtml}<div class="bubble">${sender}${doc}${text}<div class="meta">${time} ${ticks}</div></div></div>`;
}
const typingRow = `<div class="msg-row in"><div class="bubble"><span class="typing"><i></i><i></i><i></i></span></div></div>`;

/** Панель ввода сообщения */
function composer() {
  return `<div class="composer">
    <button class="btn-circle grad-light-blue">${ic('plus', 20)}</button>
    <div class="msgfield"><input placeholder="Message" />${ic('smile', 22)}</div>
    <button class="icon-btn">${ic('mic', 22)}</button>
    <button class="btn-circle grad-light-blue send-btn">${ic('send', 20)}</button>
  </div>`;
}

/** Шапка переписки */
function chatBar(name, status, opts = {}) {
  return `<div class="chat-bar">
    <div class="who">${av(name, 40, { online: opts.online })}<div><div class="nm">${name}</div><div class="st ${opts.online ? '' : 'off'}">${status}</div></div></div>
    <button class="icon-btn">${ic('video', 22)}</button>
    <button class="icon-btn">${ic('phone', 20)}</button>
    <button class="icon-btn" title="Chat info">${ic('info', 22)}</button>
  </div>`;
}

/** Пустое состояние detail (чат не выбран) */
function emptyDetail() {
  return `<div class="empty-detail">
    <div class="art" style="background:none;box-shadow:none">${logoMark(132)}</div>
    <h2>Select a chat</h2>
    <p>Pick a conversation from the list to start messaging, or create a new one.</p>
  </div>`;
}

/** Инфо-панель пользователя (3-я колонка desktop / overlay tablet) */
function infoPane(asOverlay) {
  const media = AV_GRADS.map((g, i) => `<div class="m" style="background:linear-gradient(${135 + i * 40}deg,${g[0]},${g[1]})"></div>`).join('');
  return `${asOverlay ? '<div class="overlay">' : ''}
  <aside class="info-pane" ${asOverlay ? 'style="width:480px;height:calc(100% - 96px);border-radius:24px;border:1px solid var(--divider);box-shadow:var(--shadow-pop)"' : ''}>
    <div class="info-head">${asOverlay ? `<button class="icon-btn">${ic('x', 20)}</button>` : ''}<span class="t">User Information</span>
      <button class="icon-btn">${ic('phone', 18)}</button><button class="icon-btn">${ic('dotsV', 20)}</button></div>
    <div class="info-body scroll-thin" style="overflow-y:auto">
      <div class="info-id">${av('Maxwell Williamson', 88)}<div class="nm">Maxwell Williamson</div><div class="un">@maxwill</div></div>
      <div class="info-rows">
        <div class="info-row"><span class="ic-box">${ic('info', 18)}</span><div><div class="k">About</div><div class="v">Only people can see this number 👌</div></div></div>
        <div class="info-row"><span class="ic-box">${ic('phone', 18)}</span><div><div class="k">Phone</div><div class="v">+62 857-4852-1265</div></div></div>
      </div>
      <div class="media-tabs">
        <button class="mt active">Media<span class="cnt">145</span></button>
        <button class="mt">Links<span class="cnt">12</span></button>
        <button class="mt">Docs<span class="cnt">8</span></button>
      </div>
      <div class="media-grid">${media}</div>
      <div style="height:8px;border-top:1px solid var(--divider)"></div>
      <div class="switch-row"><span class="lbl">Notifications</span><button class="tgl"></button></div>
      <div class="switch-row"><span class="lbl">Protected Chat</span><button class="tgl on"></button></div>
      <div class="switch-row danger-row"><span class="lbl">Block User</span></div>
    </div>
  </aside>${asOverlay ? '</div>' : ''}`;
}

/* ---------------------------------------------------------------- Экраны */

/** 1. Chats — список без выбранного чата (empty detail) */
function screenChatsEmpty(ff) {
  return `${chrome('chats', ff)}${master(null)}<section class="detail">${emptyDetail()}</section>`;
}

/** 2. Chats — переписка (TwoPane) */
function screenChatsConversation(ff) {
  return `${chrome('chats', ff)}${master('Maxwell Williamson')}
  <section class="detail">
    ${chatBar('Maxwell Williamson', 'Online', { online: true })}
    <div class="thread">
      <div class="date-chip">Today</div>
      ${msg('in', 'Good Morning!', '10:10')}
      ${msg('in', "Have you seen the latest design mockups? They're looking great!", '10:10')}
      ${msg('out', 'Good morning! Yes, I went through them yesterday. Really clean work 👌', '10:12')}
      ${msg('in', 'Can you send me the updated files?', '10:12')}
      ${msg('out', 'Sure, sending them right now 📤', '10:13')}
      ${typingRow}
    </div>
    ${composer()}
  </section>`;
}

/** 3. Chats — инфо-панель: desktop 1440 — 3-я колонка 320; tablet/tabletL — overlay (на 1024 три колонки не помещаются) */
function screenChatsInfo(ff) {
  const base = `${chrome('chats', ff)}${master('Maxwell Williamson')}
  <section class="detail">
    ${chatBar('Maxwell Williamson', 'Online', { online: true })}
    <div class="thread">
      <div class="date-chip">Today</div>
      ${msg('in', 'Good Morning!', '10:10')}
      ${msg('out', 'Good morning! Yes, I went through them yesterday 👌', '10:12')}
      ${msg('in', 'Can you send me the updated files?', '10:12')}
    </div>
    ${composer()}
  </section>`;
  return ff === 'desktop' ? base + infoPane(false) : base + infoPane(true);
}

/** 4. Groups — групповая переписка */
function screenGroupsConversation(ff) {
  return `${chrome('groups', ff)}
  <section class="master">
    <div class="master-head">
      <div class="searchbox">${ic('search', 18)}<input placeholder="Search" /></div>
      <button class="btn-circle grad-light-blue">${ic('plus', 20)}</button>
    </div>
    <div class="tabs" style="margin-top:8px">
      <button class="tab active">All Groups</button><button class="tab">Unread</button>
    </div>
    <div class="tiles scroll-thin">
      ${tile({ n: 'Design Team', m: 'Theresa: I have shared the files', t: '09:46', b: 3 }, true)}
      ${tile({ n: 'Family 👨‍👩‍👧', m: 'Marvin: See you on Sunday!', t: '08:12' }, false)}
      ${tile({ n: 'Flutter Devs', m: 'Cody: New release is out 🚀', t: 'Yesterday', b: 12 }, false)}
      ${tile({ n: 'Weekend Hikers', m: 'Annette: Photos from the trip', t: 'Yesterday' }, false)}
      ${tile({ n: 'Book Club', m: 'Floyd: Next meeting — Friday', t: 'Monday' }, false)}
    </div>
  </section>
  <section class="detail">
    ${chatBar('Design Team', '25 Online, 35 Members')}
    <div class="thread">
      <div class="date-chip">Today</div>
      ${msg('in', 'Guys, I have shared the Study Materials', '09:46', { sender: 'Theresa', senderColor: '#13C296', avatar: 'Theresa', doc: 'Study Materials.rar', docSize: '1.2 GB · RAR' })}
      ${msg('in', 'Thanks! Downloading now 🙌', '09:47', { sender: 'Danielle', senderColor: '#F2994A', avatar: 'Danielle' })}
      ${msg('out', 'The new chapter looks great 👌', '09:50')}
      ${msg('in', 'Can we schedule a review call tomorrow?', '09:52', { sender: 'Marvin', senderColor: '#9B51E0', avatar: 'Marvin' })}
      ${typingRow}
    </div>
    ${composer()}
  </section>`;
}

/** Цветная «плитка» иконки меню настроек */
function menuItem(icon, label, color, bg, danger = false) {
  return `<div class="menu-item" ${danger ? `style="color:${color}"` : ''}>
    <div class="sq" style="color:${color};background:${bg}">${ic(icon, 20)}</div>
    <span class="lbl">${label}</span>${ic('chevR', 18)}
  </div>`;
}

/** 5. Profile — одна колонка, контент в MaxWidthBox 560 */
function screenProfile(ff) {
  return `${chrome('profile', ff)}
  <section class="single">
    <div class="single-head"><span class="t">Profile</span>
      <button class="icon-btn">${ic('sun', 20)}</button><button class="icon-btn">${ic('dotsV', 20)}</button></div>
    <div class="single-scroll scroll-thin" style="overflow-y:auto"><div class="narrow">
      <div class="profile-card">
        ${av('John Doe', 88)}
        <div class="nm">MR. John Doe</div>
        <div class="ph">+62 857-4852-1265</div>
        <button class="btn-tonal">Edit Profile</button>
      </div>
      <div class="menu-list">
        ${menuItem('bell', 'Notification', '#1565C0', 'rgba(21,101,192,.12)')}
        ${menuItem('shield', 'Security', '#13C296', 'rgba(19,194,150,.12)')}
        ${menuItem('database', 'Data & Storage', '#F4511E', 'rgba(244,81,30,.12)')}
        ${menuItem('userPlus', 'Invite a Friend', '#7C4DFF', 'rgba(124,77,255,.12)')}
      </div>
    </div></div>
  </section>`;
}

/** 6. More — профильная карточка + полное меню */
function screenMore(ff) {
  return `${chrome('more', ff)}
  <section class="single">
    <div class="single-head"><span class="t">More</span><button class="icon-btn">${ic('search', 20)}</button></div>
    <div class="single-scroll scroll-thin" style="overflow-y:auto"><div class="narrow">
      <div class="profile-strip">
        ${av('John Doe', 56)}
        <div style="flex:1"><div class="nm">MR. John Doe</div><div class="ph">+62 857-4852-1265</div></div>
        ${ic('chevR', 20)}
      </div>
      <div class="menu-list">
        ${menuItem('bell', 'Notification', '#1565C0', 'rgba(21,101,192,.12)')}
        ${menuItem('database', 'Data and Storage', '#F4511E', 'rgba(244,81,30,.12)')}
        ${menuItem('shield', 'Security', '#13C296', 'rgba(19,194,150,.12)')}
        ${menuItem('help', 'Help Center', '#1565C0', 'rgba(21,101,192,.12)')}
        ${menuItem('userPlus', 'Invite a Friend', '#7C4DFF', 'rgba(124,77,255,.12)')}
        ${menuItem('info', 'About App', '#03A9F4', 'rgba(3,169,244,.12)')}
        ${menuItem('file', 'Term of Service', '#7C4DFF', 'rgba(124,77,255,.12)')}
        ${menuItem('lock', 'Privacy Policy', '#1565C0', 'rgba(21,101,192,.12)')}
        ${menuItem('grid', 'Other Apps', '#03A9F4', 'rgba(3,169,244,.12)')}
        ${menuItem('star', 'Rate Us', '#F2994A', 'rgba(242,153,74,.12)')}
        ${menuItem('logout', 'Logout', '#F44336', 'rgba(244,67,54,.12)', true)}
      </div>
    </div></div>
  </section>`;
}

/** Форма логина — общая для карточки и split; вход по email и паролю.
    opts.loading — отправка формы: поля disabled, на кнопке индикатор загрузки
    (соответствует TButtons isLoading — CircularProgressIndicator вместо лейбла) */
function loginForm(opts = {}) {
  const loading = opts.loading === true;
  const disCls = loading ? ' disabled' : '';
  const disAttr = loading ? ' disabled' : '';
  // В состоянии отправки поля показаны заполненными (пользователь уже ввёл данные)
  const emailVal = loading ? ' value="you@example.com"' : '';
  const passVal = loading ? ' value="password123"' : '';
  const btn = loading
    ? '<button class="btn-primary loading" disabled><span class="spinner"></span></button>'
    : '<button class="btn-primary">Войти</button>';
  return `${logoFull(40)}
  <h2>Добро пожаловать</h2>
  <div class="sub">Войдите в свой аккаунт</div>
  <label class="field-label">Email</label>
  <div class="input${disCls}">${ic('mail', 18)}<input type="email" placeholder="you@example.com"${emailVal}${disAttr} /></div>
  <label class="field-label" style="margin-top:16px">Пароль</label>
  <div class="input${disCls}">${ic('lock', 18)}<input type="password" placeholder="••••••••"${passVal}${disAttr} /></div>
  <div class="auth-forgot"><a href="#">Забыли пароль?</a></div>
  ${btn}
  <div class="auth-foot">Нет аккаунта? <a href="#">Создать</a></div>`;
}

/** 7. Auth — Login: tablet portrait — карточка 480; desktop и tablet landscape (1024) — split brand + форма.
    loading=true — состояние отправки формы (на кнопке спиннер, поля заблокированы) */
function screenAuthLogin(ff, loading = false) {
  if (ff !== 'tablet') {
    return `<section class="auth">
      <div class="auth-brand grad-blue">
        <div class="deco" style="width:220px;height:220px;top:-70px;right:-60px;transform:rotate(24deg)"></div>
        <div class="deco" style="width:140px;height:140px;top:120px;right:60px;transform:rotate(-14deg);background:rgba(255,255,255,.07)"></div>
        <div>${logoFull(44, true)}</div>
        <h1>Connect with friends, anywhere.</h1>
        <p>Fast, simple and secure messaging — now on the big screen.</p>
      </div>
      <div class="auth-form"><div class="inner">${loginForm({ loading })}</div></div>
    </section>`;
  }
  return `<section class="auth">
    <div class="blob grad-blue" style="width:420px;height:420px;top:-160px;left:-140px"></div>
    <div class="blob grad-light-blue" style="width:380px;height:380px;bottom:-160px;right:-120px"></div>
    <div class="auth-center"><div class="auth-card">${loginForm({ loading })}</div></div>
  </section>`;
}

/** 8. Onboarding — центрированная композиция 440 */
function screenOnboarding(ff) {
  return `<section class="onb">
    <div class="art">
      <div class="logo-badge grad-light-blue" style="width:104px;height:104px;border-radius:30px">${ic('group', 48)}</div>
      <div class="logo-badge grad-blue" style="position:absolute;top:26px;right:30px;width:44px;height:44px;border-radius:14px">${ic('chat', 20)}</div>
      <div class="logo-badge grad-blue" style="position:absolute;bottom:34px;left:24px;width:36px;height:36px;border-radius:12px">${ic('smile', 16)}</div>
    </div>
    <div class="dots"><i class="on"></i><i></i><i></i><i></i></div>
    <h2>Group Chatting</h2>
    <p>Connect with multiple members in a group chat — share moments, files and calls in one place.</p>
    <div class="row"><button class="skip">Skip</button><button class="btn-primary next">Next</button></div>
  </section>`;
}

/** 9. Диалог Add Friend — bottom sheet телефона → centered dialog 480 */
function screenAddFriend(ff) {
  const members = [
    { n: 'Marvin', u: '@marvin_co', added: true },
    { n: 'Courtney', u: '@court_henry', added: false },
    { n: 'Floyd', u: '@floyd_m', added: false },
    { n: 'Cody', u: '@cody_fisher', added: true },
  ];
  return `${screenChatsConversation(ff)}
  <div class="overlay"><div class="dialog">
    <div class="dialog-head"><span class="t">Add Friend</span><button class="icon-btn">${ic('x', 20)}</button></div>
    <div class="dialog-body">
      <div class="input">${ic('search', 18)}<input placeholder="Search by ID or name" /></div>
      <div style="margin-top:10px">
        ${members.map(m => `<div class="member-row">${av(m.n, 44)}
          <div class="tx"><div class="nm">${m.n}</div><div class="un">${m.u}</div></div>
          <button class="add-btn ${m.added ? 'added' : ''}">${ic(m.added ? 'checks' : 'plus', 16)}</button></div>`).join('')}
      </div>
    </div>
  </div></div>`;
}

/** Контент звонка: входящий / активный — общий для overlay и panel */
function callContent(kind) {
  if (kind === 'incoming') {
    return `<div class="call-blur-bg"></div>
    <div class="call-body">
      ${av('Anneliese', 120, { grad: ['#BA68C8', '#8E24AA'] })}
      <div class="nm">Anneliese</div>
      <div class="st">+62 857-4852-1265</div>
      <div class="st" style="margin-top:6px;color:#E8F0F9">Incoming call…</div>
    </div>
    <div class="call-controls">
      <button class="call-btn big decline"><span class="c">${ic('phoneDown', 26)}</span>Decline</button>
      <button class="call-btn big accept"><span class="c">${ic('phone', 26)}</span>Accept</button>
    </div>`;
  }
  return `<div class="call-blur-bg" style="background:linear-gradient(160deg,#8E24AA 0%,#0D1217 75%)"></div>
  <div class="call-body">
    ${av('Anneliese', 104, { grad: ['#BA68C8', '#8E24AA'] })}
    <div class="nm">Anneliese</div>
    <div class="timer">03:45</div>
  </div>
  <div class="call-controls">
    <button class="call-btn"><span class="c">${ic('micOff', 22)}</span>Mute</button>
    <button class="call-btn"><span class="c">${ic('speaker', 22)}</span>Speaker</button>
    <button class="call-btn big decline"><span class="c">${ic('phoneDown', 26)}</span>End</button>
  </div>`;
}

/** Видеозвонок — сцена камеры + PiP + шторка управления */
function videoContent() {
  return `<div class="video-scene"></div>
  <div class="pip">${av('John Doe', 40)}</div>
  <div class="video-top"><button class="icon-btn" style="color:#fff">${ic('x', 22)}</button></div>
  <div class="video-controls">
    <button class="vc-btn">${ic('zap', 22)}</button>
    <button class="shutter">${ic('camera', 28)}</button>
    <button class="vc-btn">${ic('flip', 22)}</button>
  </div>`;
}

/** 10–12. Звонки: tablet portrait — full-frame overlay; desktop и tablet landscape — панель 420×min(780, высота−80) */
function screenCall(ff, kind) {
  const content = kind === 'video' ? videoContent() : callContent(kind);
  if (ff === 'tablet') {
    return `${screenChatsConversation(ff)}<div class="call-full">${content}</div>`;
  }
  return `${screenChatsConversation(ff)}<div class="overlay"><div class="call-panel">${content}</div></div>`;
}

/* ---------------------------------------------------------------- Галереи компонентов */
/* Переиспользуемые компоненты (README §4) — рендер через те же хелперы, что и экраны */

/** Секция галереи: заголовок + содержимое */
function gSec(title, body) {
  return `<div class="g-sec"><div class="g-title">${title}</div>${body}</div>`;
}

/** К1. Базовые: иконки, аватары, логотипы, бейджи, градиенты */
function screenCompBasics() {
  const icons = Object.keys(ICONS)
    .map(n => `<div class="g-icon">${ic(n, 24)}<span class="nm">${n}</span></div>`).join('');
  const avatars = [
    av('Anneliese', 88), av('Danielle', 48, { online: true }), av('Maxwell Williamson', 40),
    av('Theresa', 28), av('Marvin', 48, { grad: ['#FF8A65', '#F4511E'] }),
  ].join('');
  const badges = ['2', '5', '9', '99+'].map(b => `<span class="badge">${b}</span>`).join('');
  return `<section class="gallery scroll-thin">
    ${gSec('Иконки · ic()', `<div class="g-row">${icons}</div>`)}
    ${gSec('Аватары · av()', `<div class="g-row">${avatars}</div>`)}
    ${gSec('Логотипы · logoMark() / logoFull()', `<div class="g-row" style="gap:28px">
      ${logoMark(40)}${logoFull(34)}
      <div class="g-dark" style="padding:12px 16px;gap:12px">${logoFull(28, true)}</div>
    </div>`)}
    ${gSec('Бейджи счётчиков · .badge', `<div class="g-row">${badges}</div>`)}
    ${gSec('Градиенты бренда', `<div class="g-row">
      <div class="g-swatch grad-blue">gradientBlue</div>
      <div class="g-swatch grad-light-blue">gradientLightBlue</div>
    </div>`)}
  </section>`;
}

/** К2. Кнопки */
function screenCompButtons() {
  const iconBtns = ['video', 'phone', 'info', 'x', 'dotsV', 'sun', 'search', 'mic']
    .map(n => `<button class="icon-btn">${ic(n, 22)}</button>`).join('');
  return `<section class="gallery scroll-thin">
    ${gSec('Иконка-кнопка 40×40 · .icon-btn', `<div class="g-row">${iconBtns}</div>`)}
    ${gSec('Круглая градиентная · .btn-circle', `<div class="g-row">
      <button class="btn-circle grad-light-blue">${ic('plus', 20)}</button>
      <button class="btn-circle grad-light-blue send-btn">${ic('send', 20)}</button>
    </div>`)}
    ${gSec('Primary · .btn-primary', `<div class="g-col g-limit">
      <button class="btn-primary" style="margin-top:0">Войти</button>
    </div>`)}
    ${gSec('Primary · загрузка · .btn-primary.loading + .spinner', `<div class="g-col g-limit">
      <button class="btn-primary loading" style="margin-top:0" disabled><span class="spinner"></span></button>
      <div style="font-size:12px;color:var(--on-variant)">Отправка формы: лейбл заменяется индикатором (TButtons isLoading → CircularProgressIndicator), геометрия и градиент кнопки сохраняются, поля формы disabled.</div>
    </div>`)}
    ${gSec('Кнопки звонка · .call-btn', `<div class="g-dark">
      <button class="call-btn"><span class="c">${ic('micOff', 22)}</span>Mute</button>
      <button class="call-btn"><span class="c">${ic('speaker', 22)}</span>Speaker</button>
      <button class="call-btn big accept"><span class="c">${ic('phone', 26)}</span>Accept</button>
      <button class="call-btn big decline"><span class="c">${ic('phoneDown', 26)}</span>End</button>
    </div>`)}
    ${gSec('Управление камерой · .vc-btn / .shutter', `<div class="g-dark" style="gap:32px">
      <button class="vc-btn">${ic('zap', 22)}</button>
      <button class="shutter">${ic('camera', 28)}</button>
      <button class="vc-btn">${ic('flip', 22)}</button>
    </div>`)}
  </section>`;
}

/** К3. Списки и строки */
function screenCompLists() {
  const tiles = [
    tile({ n: 'Anneliese', m: 'Hello, Good Morning...', t: '09:46', b: 2, on: true }, false),
    tile({ n: 'Danielle', m: 'OMG 😱 OMG...', t: '08:15', read: true }, true),
    tile({ n: 'Theresa', m: 'Hi, Morning too!', t: '06:12' }, false),
  ].join('');
  const stories = `<div class="stories" style="padding:10px 0 6px">
    <div class="story add"><div class="ring">${ic('plus', 18)}<span class="plus-badge">${ic('plus', 10)}</span></div><span class="nm">You</span></div>
    ${STORIES.slice(0, 4).map(s => `<div class="story"><div class="ring">${av(s, 48)}</div><span class="nm">${s}</span></div>`).join('')}
  </div>`;
  return `<section class="gallery scroll-thin">
    ${gSec('Тайл диалога 64 · tile()', `<div class="g-col g-limit"><div class="g-box tiles">${tiles}</div></div>`)}
    ${gSec('Пункт меню · menuItem()', `<div class="g-col g-limit"><div class="menu-list" style="margin-top:0">
      ${menuItem('bell', 'Notification', '#1565C0', 'rgba(21,101,192,.12)')}
      ${menuItem('shield', 'Security', '#13C296', 'rgba(19,194,150,.12)')}
      ${menuItem('logout', 'Logout', '#F44336', 'rgba(244,67,54,.12)', true)}
    </div></div>`)}
    ${gSec('Строка участника · .member-row', `<div class="g-col g-limit"><div class="g-box" style="padding:6px 16px">
      <div class="member-row">${av('Marvin', 44)}<div class="tx"><div class="nm">Marvin</div><div class="un">@marvin_co</div></div><button class="add-btn added">${ic('checks', 16)}</button></div>
      <div class="member-row">${av('Courtney', 44)}<div class="tx"><div class="nm">Courtney</div><div class="un">@court_henry</div></div><button class="add-btn">${ic('plus', 16)}</button></div>
    </div></div>`)}
    ${gSec('Строка «ключ-значение» · .info-row', `<div class="g-col g-limit"><div class="g-box" style="padding:10px 20px">
      <div class="info-row"><span class="ic-box">${ic('info', 18)}</span><div><div class="k">About</div><div class="v">Only people can see this number 👌</div></div></div>
      <div class="info-row"><span class="ic-box">${ic('phone', 18)}</span><div><div class="k">Phone</div><div class="v">+62 857-4852-1265</div></div></div>
    </div></div>`)}
    ${gSec('Строка-переключатель · .switch-row', `<div class="g-col g-limit"><div class="g-box">
      <div class="switch-row"><span class="lbl">Notifications</span><button class="tgl"></button></div>
      <div class="switch-row"><span class="lbl">Protected Chat</span><button class="tgl on"></button></div>
      <div class="switch-row danger-row"><span class="lbl">Block User</span></div>
    </div></div>`)}
    ${gSec('Сторис · .story', stories)}
  </section>`;
}

/** К4. Переписка */
function screenCompChat() {
  return `<section class="gallery scroll-thin">
    ${gSec('Шапка переписки · chatBar()', `<div class="g-col" style="max-width:760px"><div class="g-box">
      ${chatBar('Maxwell Williamson', 'Online', { online: true })}
    </div></div>`)}
    ${gSec('Пузыри сообщений · msg()', `<div class="g-col" style="max-width:760px;gap:12px">
      <div class="date-chip">Today</div>
      ${msg('in', 'Good Morning!', '10:10')}
      ${msg('out', 'Good morning! Yes, I went through them yesterday 👌', '10:12')}
      ${msg('in', 'I have shared the Study Materials', '09:46', { sender: 'Theresa', senderColor: '#13C296', avatar: 'Theresa', doc: 'Study Materials.rar', docSize: '1.2 GB · RAR' })}
      ${typingRow}
    </div>`)}
    ${gSec('Панель ввода · composer()', `<div class="g-col" style="max-width:760px"><div class="g-box">
      ${composer()}
    </div></div>`)}
  </section>`;
}

/** К5. Поля ввода и вкладки */
function screenCompFields() {
  return `<section class="gallery scroll-thin">
    ${gSec('Поиск · .searchbox', `<div class="g-col g-limit">
      <div class="searchbox">${ic('search', 18)}<input placeholder="Search" /></div>
    </div>`)}
    ${gSec('Текстовое поле · .input', `<div class="g-col g-limit">
      <div class="input">${ic('mail', 18)}<input type="email" placeholder="you@example.com" /></div>
      <div class="input">${ic('lock', 18)}<input type="password" placeholder="••••••••" /></div>
    </div>`)}
    ${gSec('Вкладки · .tabs', `<div class="g-col g-limit"><div class="tabs" style="padding-top:0">
      <button class="tab active">Chats</button><button class="tab">Groups</button>
      <button class="tab">Status</button><button class="tab">Calls</button>
    </div></div>`)}
  </section>`;
}

/* ---------------------------------------------------------------- Реестр */
const SCREENS = [
  { id: 'chats-empty', group: 'Чаты', title: 'Список чатов · пустой detail',
    note: 'Tablet: rail 72 + master 300 + placeholder · Desktop: sidebar 240 + master 320',
    render: screenChatsEmpty },
  { id: 'chats-conversation', group: 'Чаты', title: 'Переписка (TwoPane)',
    note: 'Список не уезжает при открытии чата; bubbles, typing, composer — общие с phone',
    render: screenChatsConversation },
  { id: 'chats-info', group: 'Чаты', title: 'Инфо-панель пользователя',
    note: 'Desktop 1440: третья колонка 320 (ThreePane) · Tablet (обе ориентации): overlay-панель 480 поверх',
    render: screenChatsInfo },
  { id: 'groups-conversation', group: 'Группы', title: 'Групповая переписка',
    note: 'Имена отправителей цветом, аватар 28 у входящих, карточка документа',
    render: screenGroupsConversation },
  { id: 'profile', group: 'Профиль', title: 'Профиль',
    note: 'Одна колонка: MaxWidthBox 560 по центру, tiles не растягиваются',
    render: screenProfile },
  { id: 'more', group: 'Профиль', title: 'Ещё (More)',
    note: 'Профильная карточка-строка + полное меню настроек в MaxWidthBox 560',
    render: screenMore },
  { id: 'auth-login', group: 'Авторизация', title: 'Login',
    note: 'Вход по email и паролю, без соцкнопок · Tablet portrait: карточка 480 · Tablet landscape / Desktop: split — brand ≤40% + форма 440',
    render: ff => screenAuthLogin(ff) },
  { id: 'auth-login-loading', group: 'Авторизация', title: 'Login · отправка формы',
    note: 'После нажатия «Войти»: поля disabled, на кнопке спиннер вместо лейбла (.btn-primary.loading) — геометрия кнопки не меняется',
    render: ff => screenAuthLogin(ff, true) },
  { id: 'auth-onboarding', group: 'Авторизация', title: 'Onboarding',
    note: 'Центрированная композиция max 440 на обоих форм-факторах',
    render: screenOnboarding },
  { id: 'modal-add-friend', group: 'Диалоги', title: 'Add Friend',
    note: 'Bottom sheet телефона → centered dialog 480, radius 16, shadow2',
    render: screenAddFriend },
  { id: 'call-incoming', group: 'Звонки', title: 'Входящий звонок',
    note: 'Tablet portrait: full-frame overlay · Tablet landscape / Desktop: панель 420×780 поверх dim shell',
    render: ff => screenCall(ff, 'incoming') },
  { id: 'call-active', group: 'Звонки', title: 'Активный звонок',
    note: 'Таймер, Mute / Speaker / End · Accept #00C853, End #F44336',
    render: ff => screenCall(ff, 'active') },
  { id: 'call-video', group: 'Звонки', title: 'Видеозвонок',
    note: 'Camera-сцена, PiP 96×128, Flash · Shutter (ring #40C4FF) · Flip',
    render: ff => screenCall(ff, 'video') },
  { id: 'comp-basics', group: 'Компоненты', title: 'Базовые',
    note: 'Иконки · аватары · логотипы · бейджи · градиенты — ic() / av() / logoMark() / logoFull() / .badge',
    render: screenCompBasics },
  { id: 'comp-buttons', group: 'Компоненты', title: 'Кнопки',
    note: '.icon-btn · .btn-circle · .btn-primary · .call-btn · .vc-btn / .shutter',
    render: screenCompButtons },
  { id: 'comp-lists', group: 'Компоненты', title: 'Списки и строки',
    note: 'tile() · menuItem() · .member-row · .info-row · .switch-row · .story',
    render: screenCompLists },
  { id: 'comp-chat', group: 'Компоненты', title: 'Переписка',
    note: 'chatBar() · msg() · typingRow · composer() · .date-chip',
    render: screenCompChat },
  { id: 'comp-fields', group: 'Компоненты', title: 'Поля ввода и вкладки',
    note: '.searchbox · .input · .tabs',
    render: screenCompFields },
];
