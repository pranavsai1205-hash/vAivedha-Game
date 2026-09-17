const state = { step: 0, memory: 0, started: false };
const scenes = [
  { label: 'PROLOGUE', title: 'The First Meeting', timeline: 'City of Echoes', rasa: 'Shringara', text: 'A familiar road waits beneath the evening sky. Something in the air feels remembered, though Aarav cannot say from which life.', dialogue: 'Aarav: “I remember this road… but not from this life.”', choices: [['Explore the road','explore'],['Search for a memory','remember']] },
  { label: 'DISCOVERY', title: 'A Signal in the Rain', timeline: 'City of Echoes', rasa: 'Adbhuta', text: 'A golden signal flickers beyond a closed market. The route is safe, but the memory is incomplete.', dialogue: 'Meera: “Some places remember us, even when we forget them.”', choices: [['Follow the signal','follow'],['Study the surroundings','observe']] },
  { label: 'ENCOUNTER', title: 'The Unreachable Light', timeline: 'City of Echoes', rasa: 'Karuna', text: 'Meera appears exactly as the reference memory shows her: radiant, familiar, and just beyond the changing road. The world begins to shift.', dialogue: 'Aarav: “Wait… please. Not again.”', choices: [['Move toward her','approach'],['Hold the memory','hold']] },
  { label: 'TRANSITION', title: 'Another Life Begins', timeline: 'Kingdom of the Weaver', rasa: 'Veera', text: 'The street becomes stone. The city becomes a kingdom. Aarav wakes with one new memory fragment and the same unanswered question.', dialogue: 'Unknown voice: “You may change the road. You cannot command the destination.”', choices: [['Enter the training grounds','train'],['Inspect the memory fragment','inspect']] }
];
const $ = id => document.getElementById(id);
function render() {
  const s = scenes[Math.min(state.step, scenes.length - 1)];
  $('sceneLabel').textContent = s.label;
  $('sceneTitle').textContent = s.title;
  $('sceneText').textContent = s.text;
  $('timeline').textContent = s.timeline;
  $('rasa').textContent = s.rasa;
  $('memory').textContent = `${state.memory} / 3`;
  $('dialogue').textContent = s.dialogue;
  $('choices').replaceChildren(...s.choices.map(([label, action]) => {
    const b = document.createElement('button'); b.textContent = label; b.dataset.action = action; return b;
  }));
}
function advance(action) {
  if (!state.started) return;
  if (['remember','observe','hold','inspect'].includes(action)) state.memory = Math.min(3, state.memory + 1);
  state.step = Math.min(state.step + 1, scenes.length - 1);
  render();
}
$('startBtn').addEventListener('click', () => { state.started = true; state.step = 0; state.memory = 0; render(); $('startBtn').textContent = 'Restart First Echo'; });
$('choices').addEventListener('click', e => { if (e.target.matches('button')) advance(e.target.dataset.action); });
render();
