extends RefCounted

# Personal prompts, not scored questions. Responses match option order.
const QUESTIONS := [
	{
		"question": "Have you had a cervical screening test before?",
		"options": ["Yes", "No", "I'm not sure"],
		"responses": [
			"Thanks for sharing. Tell me what worked well, or what you would like to be different this time.",
			"That's okay. I'll explain each step before we begin, and you can ask questions at any time.",
			"That's okay. We can check your screening history together and talk through what happens next.",
		],
	},
	{
		"question": "Have you heard about the option to collect your own sample?",
		"options": ["Yes", "No", "I'm not sure"],
		"responses": [
			"We can talk about whether collecting your own sample feels right for you. Your healthcare professional will explain how to use the small swab and give you time to ask questions.",
			"You may be able to collect your own sample in a private space using a small swab. Your healthcare professional will explain what to do and offer support if you would like it.",
			"We can explain both options at your pace: collecting your own sample in private, or having a healthcare professional collect it. You can ask questions before choosing.",
		],
	},
	{
		"question": "Do you have a preference for how your sample is collected?",
		"options": ["I'd like to collect it myself", "I'd prefer a healthcare professional", "I'd like to discuss my options"],
		"responses": [
			"We can discuss whether collecting your own sample is suitable for you. Your healthcare professional will explain how to use the swab, with clear instructions you can follow in private.",
			"With your permission, your healthcare professional uses an instrument called a speculum to help collect a sample from your cervix. They explain each step, and you can ask to pause or stop.",
			"We can discuss both options and what suits your circumstances. You can ask questions before deciding.",
		],
	},
	{
		"question": "Are you feeling worried about any part of the test?",
		"options": ["Yes", "No", "I'm not sure how I feel yet"],
		"responses": [
			"Thank you for telling me. We can talk about your concerns and take things at your pace. You can ask to pause or stop at any time.",
			"I'm glad you feel ready. You are still in control and can ask to pause or stop at any time, even after we begin.",
			"That's completely okay. We can take one step at a time. You can ask to pause or stop at any time.",
		],
	},
	{
		"question": "Would you like me to explain each step as we go?",
		"options": ["Yes, that would help", "Just a brief explanation, please", "I'm not sure yet"],
		"responses": [
			"Of course. I'll explain each step and check you are ready before continuing. Tell me straight away if anything hurts.",
			"Of course. I'll keep it brief and check you are comfortable. You can ask for more detail or ask to stop whenever you need.",
			"We can start with a brief explanation and adjust as we go. You can always ask questions or tell me to pause.",
		],
	},
]

const AFTERCARE := [
	{"speaker": "HEALTHCARE PROFESSIONAL · YOUR SAMPLE", "text": "Your collected sample is sent to a pathology laboratory to check for HPV, a virus that can cause changes to cervical cells. The laboratory sends the results to your healthcare provider."},
	{"speaker": "HEALTHCARE PROFESSIONAL · YOUR RESULTS", "text": "Results usually take about two weeks, but timing can vary. Before leaving, agree with your healthcare provider how they will contact you. If you have not heard within a few weeks, contact the clinic."},
	{"speaker": "HEALTHCARE PROFESSIONAL · NEXT SCREEN", "text": "For most eligible people, routine screening is every five years when no earlier follow-up is needed. Your result and healthcare provider will guide your next steps."},
	{"speaker": "HEALTHCARE PROFESSIONAL · FOLLOW-UP", "text": "An HPV-positive result does not mean you have cancer. Your healthcare provider will explain any further tests or follow-up you need."},
]
