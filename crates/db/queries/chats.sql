--! new_chat
INSERT INTO chats 
    (user_id, organisation_id, user_request, prompt)
VALUES
    (:user_id, :organisation_id, :user_request, :prompt);
    
--! update_chat
UPDATE chats 
SET 
    response = :response
WHERE
    user_id = current_app_user()
AND 
    id = :chat_id
AND     
    organisation_id IN (SELECT id FROM organisations WHERE user_id = current_app_user());

--! chats : (response?)
SELECT
    id,
    user_id, 
    organisation_id, 
    user_request,
    prompt,
    response,
    created_at,
    updated_at
FROM 
    chats
WHERE
    user_id = current_app_user()
AND 
    organisation_id IN (SELECT id FROM organisations WHERE user_id = current_app_user())
ORDER BY updated_at;