event_inherited();

dialogue = {
	start: {
        pages: [
            "* A bed of flowers.",
            "* What do you think?"
        ],
        choices: [
            { text: "They're beautiful.", next: "flowers_nice" },
            { text: "They're just weeds.", next: "flowers_rude" }
        ]
    },

    flowers_nice: {
        pages: [
            "* You crouch down and smell one.",
            "* It smells like nothing."
        ],
        choices: [
            { text: "That's disappointing.", next: "flowers_end" },
            { text: "Try another one.", next: "flowers_nice" }
        ]
    },

    flowers_rude: {
        pages: [
            "* The flowers seem to wilt slightly."
        ],
        choices: [
            { text: "...Sorry.", next: "flowers_end" }
        ]
    },

    flowers_end: {
        pages: [
            "* You step away from the flowers."
        ],
        choices: []
    }
}