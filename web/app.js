const app = document.getElementById('app');
const tabs = document.querySelectorAll('.tab');
const panels = document.querySelectorAll('.panel');

const state = {
  frameworkMap: {}
};

function post(name, data = {}) {
  return fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
}

function escapeHTML(value) {
  return String(value ?? '').replace(/[&<>"']/g, char => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  }[char]));
}

function renderTable(targetId, headers, rows) {
  const target = document.getElementById(targetId);

  if (!rows || rows.length === 0) {
    target.innerHTML = '<div class="error">No data.</div>';
    return;
  }

  target.innerHTML = `
    <table>
      <thead>
        <tr>${headers.map(header => `<th>${escapeHTML(header.label)}</th>`).join('')}</tr>
      </thead>
      <tbody>
        ${rows.map(row => `
          <tr>
            ${headers.map(header => `<td>${escapeHTML(header.render ? header.render(row) : row[header.key])}</td>`).join('')}
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;
}

function showError(targetId, data) {
  document.getElementById(targetId).innerHTML = `<div class="error">${escapeHTML(data?.error || 'Request failed')}</div>`;
}

tabs.forEach(tab => {
  tab.addEventListener('click', () => {
    tabs.forEach(item => item.classList.remove('active'));
    panels.forEach(item => item.classList.remove('active'));
    tab.classList.add('active');
    document.getElementById(`tab-${tab.dataset.tab}`).classList.add('active');
  });
});

document.getElementById('close-btn').addEventListener('click', () => {
  post('tracker:close');
});

document.getElementById('refresh-btn').addEventListener('click', () => {
  post('tracker:refresh');
});

document.getElementById('ban-form').addEventListener('submit', event => {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  post('tracker:insertBan', Object.fromEntries(form.entries()));
});

window.addEventListener('message', event => {
  const { action, data, frameworkMap } = event.data || {};

  if (action === 'tracker:open') {
    state.frameworkMap = frameworkMap || {};
    app.classList.remove('hidden');
    renderFrameworkMap();
  }

  if (action === 'tracker:close') {
    app.classList.add('hidden');
  }

  if (action === 'tracker:setLivePlayers') {
    if (!data?.ok) return showError('live-content', data);

    renderTable('live-content', [
      { key: 'id', label: 'ID' },
      { key: 'fivemName', label: 'Steam/FiveM' },
      { label: 'Character', render: row => `${row.firstname || ''} ${row.lastname || ''}`.trim() },
      { key: 'citizenid', label: 'Citizen ID' },
      { key: 'sourceplayer', label: 'Source Player' },
      { label: 'Coords', render: row => `${row.coords?.x}, ${row.coords?.y}, ${row.coords?.z}` },
      { key: 'status', label: 'Status' }
    ], data.players || []);
  }

  if (action === 'tracker:setCharacters') {
    if (!data?.ok) return showError('characters-content', data);

    renderTable('characters-content', [
      { key: 'id', label: 'Identifier' },
      { key: 'name', label: 'Name' },
      { label: 'Raw JSON', render: row => JSON.stringify(row.raw || {}) }
    ], data.characters || []);
  }

  if (action === 'tracker:setBans') {
    if (!data?.ok) return showError('bans-content', data);

    renderTable('bans-content', [
      { key: 'name', label: 'Name' },
      { key: 'license', label: 'License' },
      { key: 'discord', label: 'Discord' },
      { key: 'ip', label: 'IP' },
      { key: 'reason', label: 'Reason' },
      { key: 'expire', label: 'Expire' },
      { key: 'bannedby', label: 'Banned By
