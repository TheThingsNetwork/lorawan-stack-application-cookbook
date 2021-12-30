db.createCollection("uplink_messages");

db.uplink_messages.createIndex({
  "uplink_message.network_ids.net_id": 1,
  "uplink_message.network_ids.tenant_id": 1,
  "end_device_ids.application_ids.application_id": 1,
});

db.uplink_messages.createIndex({
  "uplink_message.network_ids.net_id": 1,
  "uplink_message.network_ids.tenant_id": 1,
  "end_device_ids.application_ids.application_id": 1,
  "end_device_ids.device_id": 1,
});

db.uplink_messages.createIndex({
  received_at: 1,
});
