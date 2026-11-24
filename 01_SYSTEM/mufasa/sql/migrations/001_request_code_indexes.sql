CREATE INDEX IF NOT EXISTS ix_request_audit ON access_audit (request_id);
CREATE INDEX IF NOT EXISTS ix_request_technical_logs ON technical_logs (request_id);
