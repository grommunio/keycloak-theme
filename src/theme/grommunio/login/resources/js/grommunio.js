/* SPDX-License-Identifier: AGPL-3.0-or-later */
/* SPDX-FileCopyrightText: 2026 grommunio GmbH */
document.documentElement.dataset.host = location.hostname;

/* html.gl-legacy: engines without :is(), e.g. the EdgeHTML WebView of the
   Outlook sign-in window (keep this file ES5) */
(function () {
  var root = document.documentElement;
  try {
    document.querySelector(':is(html)');
    return;
  } catch (e) {}
  root.classList.add('gl-legacy');

  /* EdgeHTML resolves url() in custom properties against the page */
  var src = document.currentScript && document.currentScript.src;
  var base = src && src.match(/^(.*\/)js\/grommunio\.js(\?.*)?$/);
  if (base) {
    var img = base[1] + 'img/';
    root.style.setProperty('--gl-logo', 'var(--brand-logo, url(' + img + 'logo.svg))');
    root.style.setProperty('--gl-bg-overlay', 'var(--brand-bg-overlay, url(' + img + 'pattern.svg))');
  }

  /* stand-ins for :focus-within and :has() */
  var FOCUS = '.pf-v5-c-form-control, .pf-v5-c-input-group, .pf-v5-c-data-list__item';
  document.addEventListener('focusin', function (e) {
    var el = e.target;
    while (el && el.closest && (el = el.closest(FOCUS))) {
      el.classList.add('gl-focus');
      el = el.parentElement;
    }
  });
  document.addEventListener('focusout', function () {
    var list = document.querySelectorAll('.gl-focus');
    for (var i = 0; i < list.length; i++)
      list[i].classList.remove('gl-focus');
  });
  document.addEventListener('DOMContentLoaded', function () {
    if (document.querySelector('.pf-v5-c-login__main-header-utilities'))
      root.classList.add('gl-utils');
    var groups = document.querySelectorAll('.pf-v5-c-input-group');
    for (var i = 0; i < groups.length; i++)
      if (groups[i].querySelector('.pf-m-error'))
        groups[i].classList.add('gl-error');
  });
})();
