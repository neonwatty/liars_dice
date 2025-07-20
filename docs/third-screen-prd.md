# Liars’ Dice Probability Watch App – PRD (Concise with Confirmed‑Hand)

---

## 1. Overview

**Purpose**  
Fast and intuitive bid probability guidance on wrist, now with optional confirmed-hand input for sharper estimates.

**Goals**

- Simple Crown + tap UI
- Instant probability & break-even display
- Silent, precise hand-entry via voice/manual
- Minimal, focused screens

---

## 2. Screens & Navigation

### Screen 1 – Select Total Dice

- Header: `Dice in Play`
- Large number (1–40) adjusted by Crown
- Right-arrow icon → Screen 2

### Screen 2 – Bid Probability

- Header: `Break‑even: K₀`
- Large bid **k** (Crown-adjustable) and color-coded probability **%**
- “My Dice” row (0–6) with mic icon
- Left-arrow icon → Screen 1

### Screen 3 – Hand-Entry (Voice + Manual)

- Triggered only when My Dice > 0
- Shows N dice icons (N = My Dice)
- Tap to select die, Crown to set face (1–6)
- Long-press or mic launch voice dictation for selected die
- Left-arrow icon → back to Screen 2 (probabilities recomputed)

---

## 3. Confirmed‑Hand Probability Engine (Screen 3)

Upon confirmation of actual dice faces:

- Let **h_f** = number of user dice matching bid face _f_
- Compute **k' = k – h_f**, **n_unknown = n_total – MyDice**
- If _k'_ ≤ 0 → **P = 100%**
- Else:

P = sum\_{x=k'}^{n_unknown} C(n_unknown, x) (1/6)^x (5/6)^(n_unknown – x)

This uses conditional probability informed by known dice, yielding much more accurate estimates than the unknown‑dice model.

---

## 4. UX & State Logic

- **Screen 2** remains unchanged by Screen 3 outcomes.
- Confirmed-hand probability shown **only** on Screen 3.
- If Screens 1 or 2 are modified (e.g., total dice or My Dice reset), Screen 3 data is cleared and must be reentered.
- Navigation and screen transitions are isolated and intuitive.

---

## 5. Edge Cases

- **k' ≤ 0** → P = 100%
- Enforce **My Dice ≤ total dice**
- Reset hand-entry if upstream changes occur

---

## Summary

Screen 3 now features a Confirmed-Hand Probability Engine, delivering precise, face-aware odds while preserving the simplicity and independence of the main bid UI. Gameplay integrity and wrist-based ease remain priorities.
