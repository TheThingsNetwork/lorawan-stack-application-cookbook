CREATE TABLE IF NOT EXISTS tts_uplink_messages
(
  net_id            LowCardinality(Nullable(FixedString(6))),
  tenant_id         LowCardinality(Nullable(String)),
  cluster_id        LowCardinality(Nullable(String)),
  application_id    String,
  device_id         String,
  join_eui          Nullable(FixedString(16)), -- Hex-encoded
  dev_eui           Nullable(FixedString(16)), -- Hex-encoded
  dev_addr          Nullable(FixedString(8)),  -- Hex-encoded
  correlation_ids   Array(String),
  received_at       DateTime64(6),
  session_key_id    Nullable(String), -- Base64-encoded
  f_port            UInt8,
  f_cnt             Nullable(UInt32),
  frm_payload       String, -- Base64-encoded
  bandwidth         UInt64, -- in Hz
  spreading_factor  UInt8,
  coding_rate       Nullable(LowCardinality(String)),
  frequency         Nullable(UInt64), -- in Hz
  consumed_airtime  Nullable(UInt64),  -- in nanoseconds

  rx_metadata_forwarder_net_ids     Array(Nullable(FixedString(6))),
  rx_metadata_forwarder_tenant_ids  Array(Nullable(String)),
  rx_metadata_forwarder_cluster_ids Array(Nullable(String)),
  rx_metadata_gateway_ids           Array(Nullable(String)),
  rx_metadata_gateway_euis          Array(Nullable(FixedString(16))),
  rx_metadata_gateway_rssis         Array(Float32),
  rx_metadata_gateway_signal_rssis  Array(Nullable(Float32)),
  rx_metadata_gateway_channel_rssis Array(Nullable(Float32)),
  rx_metadata_gateway_snrs          Array(Float32),

  decoded_payload_keys              Array(String),
  decoded_payload_values            Array(Nullable(Float32))
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(received_at)
ORDER BY (net_id, tenant_id, application_id, device_id, received_at)
;

CREATE TABLE IF NOT EXISTS tts_uplink_message_decoded_payloads
(
  net_id            LowCardinality(Nullable(FixedString(6))),
  tenant_id         LowCardinality(Nullable(String)),
  application_id    String,
  device_id         String,
  received_at       DateTime64(6),

  f_port            UInt8,
  f_cnt             Nullable(UInt32),

  decoded_payload_key   String,
  decoded_payload_value Nullable(Float32)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(received_at)
ORDER BY (net_id, tenant_id, application_id, device_id, received_at)
;

CREATE MATERIALIZED VIEW IF NOT EXISTS tts_uplink_message_decoded_payloads_mv TO tts_uplink_message_decoded_payloads AS
SELECT net_id, tenant_id, application_id, device_id, received_at,
  f_port, f_cnt,
  decoded_payload_key, decoded_payload_value
FROM tts_uplink_messages
ARRAY JOIN
  decoded_payload_keys AS decoded_payload_key,
  decoded_payload_values AS decoded_payload_value
;

CREATE TABLE IF NOT EXISTS tts_uplink_message_rx_metadata
(
  net_id            LowCardinality(Nullable(FixedString(6))),
  tenant_id         LowCardinality(Nullable(String)),
  application_id    String,
  device_id         String,
  received_at       DateTime64(6),

  bandwidth         UInt64, -- in Hz
  spreading_factor  UInt8,
  coding_rate       LowCardinality(Nullable(String)),
  frequency         Nullable(UInt64), -- in Hz
  consumed_airtime  Nullable(UInt64),  -- in nanoseconds

  rx_metadata_forwarder_net_id     Nullable(FixedString(6)),
  rx_metadata_forwarder_tenant_id  Nullable(String),
  rx_metadata_forwarder_cluster_id Nullable(String),
  rx_metadata_gateway_id           Nullable(String),
  rx_metadata_gateway_eui          Nullable(FixedString(16)),
  rx_metadata_gateway_rssi         Float32,
  rx_metadata_gateway_signal_rssi  Nullable(Float32),
  rx_metadata_gateway_channel_rssi Nullable(Float32),
  rx_metadata_gateway_snr          Float32
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(received_at)
ORDER BY (net_id, tenant_id, application_id, device_id, received_at)
;

CREATE MATERIALIZED VIEW IF NOT EXISTS tts_uplink_message_rx_metadata_mv TO tts_uplink_message_rx_metadata AS
SELECT net_id, tenant_id, application_id, device_id, received_at,
  bandwidth, spreading_factor, coding_rate, frequency, consumed_airtime,
  rx_metadata_forwarder_net_id,
  rx_metadata_forwarder_tenant_id,
  rx_metadata_forwarder_cluster_id,
  rx_metadata_gateway_id,
  rx_metadata_gateway_eui,
  rx_metadata_gateway_rssi,
  rx_metadata_gateway_signal_rssi,
  rx_metadata_gateway_channel_rssi,
  rx_metadata_gateway_snr
FROM tts_uplink_messages
ARRAY JOIN
  rx_metadata_forwarder_net_ids AS rx_metadata_forwarder_net_id,
  rx_metadata_forwarder_tenant_ids AS rx_metadata_forwarder_tenant_id,
  rx_metadata_forwarder_cluster_ids AS rx_metadata_forwarder_cluster_id,
  rx_metadata_gateway_ids AS rx_metadata_gateway_id,
  rx_metadata_gateway_euis AS rx_metadata_gateway_eui,
  rx_metadata_gateway_rssis AS rx_metadata_gateway_rssi,
  rx_metadata_gateway_signal_rssis AS rx_metadata_gateway_signal_rssi,
  rx_metadata_gateway_channel_rssis AS rx_metadata_gateway_channel_rssi,
  rx_metadata_gateway_snrs AS rx_metadata_gateway_snr
;
