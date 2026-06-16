-- Trigger function: block team_id change on users who are referenced in tickets
CREATE OR REPLACE FUNCTION prevent_user_team_change_if_tickets_exist()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.team_id IS DISTINCT FROM NEW.team_id THEN
    IF EXISTS (
      SELECT 1 FROM tickets
      WHERE created_by = OLD.id OR assigned_to = OLD.id
    ) THEN
      RAISE EXCEPTION 'Cannot change user team: user is referenced in existing tickets as created_by or assigned_to';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_user_team_change
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION prevent_user_team_change_if_tickets_exist();
