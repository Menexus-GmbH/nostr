import 'dart:io';
import 'package:dart_nostr/nostr/model/event.dart';
import 'package:dart_nostr/nostr/model/ok.dart';
import 'package:meta/meta.dart';

import '../model/nostr_event_key.dart';
import 'exceptions.dart';
import 'utils.dart';

@protected

/// This is responsible for registering and retrieving relays [WebSocket]s that are connected to the app.
abstract class NostrRegistry {
  /// This is the registry which will have all relays [WebSocket]s.
  static final relaysWebSocketsRegistry = <String, WebSocket>{};

  ///  This is the registry which will have all events.
  static final eventsRegistry = <NostrEventKey, NostrEvent>{};

  static final okCommandCallBacks = <String,
      void Function(
    NostrEventOkCommand ok,
  )?>{};

  /// Registers a [WebSocket] to the registry with the given [relayUrl].
  /// If a [WebSocket] is already registered with the given [relayUrl], it will be replaced.
  static WebSocket registerRelayWebSocket({
    required String relayUrl,
    required WebSocket webSocket,
  }) {
    relaysWebSocketsRegistry[relayUrl] = webSocket;
    return relaysWebSocketsRegistry[relayUrl]!;
  }

  /// Returns the [WebSocket] registered with the given [relayUrl].
  static WebSocket? getRelayWebSocket({
    required String relayUrl,
  }) {
    final targetWebSocket = relaysWebSocketsRegistry[relayUrl];

    if (targetWebSocket != null) {
      final relay = targetWebSocket;

      return relay;
    } else {
      NostrClientUtils.log(
        "No relay is registered with the given url: $relayUrl, did you forget to register it?",
      );

      throw RelayNotFoundException(relayUrl);
    }
  }

  /// Returns all [WebSocket]s registered in the registry.
  static List<MapEntry<String, WebSocket>> allRelaysEntries() {
    return relaysWebSocketsRegistry.entries.toList();
  }

  /// Clears all registries.
  static void clearAllRegistries() {
    return relaysWebSocketsRegistry.clear();
  }

  /// Wether a [WebSocket] is registered with the given [relayUrl].
  static bool isRelayRegistered(String relayUrl) {
    return relaysWebSocketsRegistry.containsKey(relayUrl);
  }

  static bool isEventRegistered(NostrEvent event) {
    return eventsRegistry.containsKey(eventUniqueId(event));
  }

  static NostrEvent registerEvent(NostrEvent event) {
    eventsRegistry[eventUniqueId(event)] = event;

    return eventsRegistry[eventUniqueId(event)]!;
  }

  static NostrEventKey eventUniqueId(NostrEvent event) {
    return event.uniqueKey();
  }

  static bool unregisterRelay(String relay) {
    final isUnregistered = relaysWebSocketsRegistry.remove(relay) != null;

    return isUnregistered;
  }

  static void registerOkCommandCallBack(
    String associatedEventId,
    void Function(NostrEventOkCommand ok)? onOk,
  ) {
    okCommandCallBacks[associatedEventId] = onOk;
  }

  static void Function(
    NostrEventOkCommand ok,
  )? getOkCommandCallBack(String associatedEventIdWithOkCommand) {
    return okCommandCallBacks[associatedEventIdWithOkCommand];
  }
}
