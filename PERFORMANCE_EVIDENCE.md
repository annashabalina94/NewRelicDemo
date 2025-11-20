# Performance Evidence Report

## 1. Test Environment (Baseline)
- Device: iPhone 16 Pro
- OS: iOS 18.2
- Build: Debug (assumed) – keep identical for comparison
- Agent Version: 7.5.5 (baseline / good)
- Scenario: SwiftUI TabView embedding a single UIKit controller (Minimal repro) + rapid automated tab switching + manual tab taps (~20)
- Features Disabled: None (full default feature set)

## 2. Automated Rapid Tab Switch Test (100 iterations)
| Metric | Value |
|--------|-------|
| Total Duration | 2.98 s |
| Avg Switch Latency | 29.76 ms |
| Max Switch | 81.68 ms |
| Min Switch | 8.28 ms |
| Iterations | 100 |

Notes: All timings captured via in-app instrumentation before UI settling; no visible jank; frame pacing subjectively smooth.

## 3. Time Profiler Summary (18.745 s capture)
| Thread | CPU Time | % Total | Assessment |
|--------|----------|--------|------------|
| Main Thread | 1.58 s | 52.3% | Healthy UI load |
| NewRelic::WorkQueue::task_thread | 0.672 s | 22.4% | Background processing (expected) |
| dispatch_workloop_worker_thread | 0.243 s | 8.1% | System tasks |
| dispatch_workloop_worker_thread | 0.120 s | 4.0% | Background ops |
| Other workers (each) | 0.060–0.095 s | 2–3% | Balanced |
| TOTAL CPU | 3.00 s | 100% | Efficient (≈16% utilization) |

Heaviest stack dominated by normal UI event loop (CFRunLoopRun, UIUpdateSequence), not New Relic synchronous work. No sustained main-thread monopolization by monitoring code.

## 4. Architectural Health Indicators (7.5.5)
- New Relic work isolated to dedicated background thread.
- Main Thread <60% CPU during interaction (good for responsiveness).
- Total CPU consumed modest (3.0 s of 18.7 s sample ≈16%).
- Pattern: Burst + idle phases (battery & thermal friendly).

## 5. Baseline Expectations (Targets for Comparison)
| Indicator | Baseline | Regression Signal |
|-----------|----------|-------------------|
| Main Thread % | ~52% | >70% sustained with NR frames |
| NewRelic background thread % | ~22% | Shift of work to Main Thread |
| Total CPU Utilization | ~16% | Significantly higher (e.g. >35%) |
| Max Tab Switch | 81.68 ms | Frequent spikes >120 ms |
| Avg Tab Switch | 29.76 ms | Increase >40–50 ms |

## 6. Next Step: Capture Regression (7.5.11)
Perform identical procedure changing only agent version:
1. Upgrade package to 7.5.11 (SPM resolution). Ensure clean build (Product > Clean Build Folder).
2. Confirm `Package.resolved` shows version 7.5.11.
3. Launch with no feature flags disabled (baseline regression scenario).
4. Run the 100-iteration rapid tab switch test once – record metrics.
5. Manually tap tabs (~20) while recording a Time Profiler trace (same duration ~18–20 s).
6. Optional: Run Core Animation profile concurrently (look for long frames / dropped frames). Record longest frame duration and frame rate stability.
7. Export: Save Time Profiler trace (.trace), capture screenshot of Threads view with percentages, and heaviest stack sample showing New Relic presence (if any) on Main Thread.
8. Repeat with environment variable `NR_DISABLE_FLAGS=DefaultInteractions,InteractionTracing,AutoCollectLogs` to measure mitigation impact.

## 7. Comparison Template (Fill After 7.5.11 Tests)
| Metric | 7.5.5 | 7.5.11 (default) | 7.5.11 (flags disabled) |
|--------|-------|------------------|-------------------------|
| Avg Tab Switch (ms) | 29.76 | TBD | TBD |
| Max Tab Switch (ms) | 81.68 | TBD | TBD |
| Total Test Duration (s) | 2.98 | TBD | TBD |
| Main Thread % CPU | 52.3% | TBD | TBD |
| NewRelic BG Thread % | 22.4% | TBD | TBD |
| Total CPU Time (s) | 3.00 | TBD | TBD |
| Overall Utilization % | 16% | TBD | TBD |
| Longest Frame (ms)* | < (not captured) | TBD | TBD |
| Dropped Frames (qualitative) | None | TBD | TBD |
| Battery / Thermal (qualitative) | Cool | TBD | TBD |

*From Core Animation or Frame Meter if collected.

## 8. Evidence Packaging Checklist (Support Submission)
- [ ] Minimal repro source (this repository)
- [ ] Baseline metrics table (7.5.5)
- [ ] Regression metrics table (7.5.11)
- [ ] Mitigation metrics (flags disabled)
- [ ] Time Profiler screenshots (baseline vs regression)
- [ ] .trace files (zipped)
- [ ] Core Animation / Frame drops data (if available)
- [ ] Description of identical test procedure & environment
- [ ] Statement isolating variable: only SDK version changed

## 9. Observations Placeholder (Fill After Regression)
Add concise bullet points contrasting stack samples, thread distribution, and any main-thread blocking functions introduced in 7.5.11.

---
Update this document after capturing 7.5.11 results to finalize the comparative evidence.
