---
layout: topic
title: PeerManager
code: True
---

<!-- uncomment to add
## Notes
-->
## History

- `NetEventsInterface` was introduced with [#10756 - swap out signals for an interface class](https://github.com/bitcoin/bitcoin/pull/10756) to replace signals.

- net_processing logic started moving into `PeerManager`(then `PeerLogicValidation`) with [#19704 - net processing: move ProcessMessage() to PeerLogicValidation](https://github.com/bitcoin/bitcoin/pull/19704) and [#19791 - net processing: Move Misbehaving() to PeerManager](https://github.com/bitcoin/bitcoin/pull/19791).

- Rename from `PeerLogicValidation` to `PeerManager` as part of [#19791 - net processing: Move Misbehaving() to PeerManager](https://github.com/bitcoin/bitcoin/pull/19791)

- Split into interface and implementation (`PeerManagerImpl`) with [#20811 - move net_processing implementation details out of header](https://github.com/bitcoin/bitcoin/pull/20811)

<!-- uncomment to add
## Resources
-->
