import flatpickr from "flatpickr"
import "flatpickr/dist/themes/confetti.css" // A path to the theme CSS

flatpickr(".datepicker", {minDate: "today", dateFormat: "d-m-Y"})
