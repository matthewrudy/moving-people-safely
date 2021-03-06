# Changelog
All notable changes to this project will be documented in this file.

## 2018-02
### Changed
- Improved Release Status text and easier editing
- Better defaults for prisoner location if NOMIS API is down
- Better wording for information on journies
- Improved wording and usability in gangs section
- Improved display of alerts in court reciever view
- All cancelled PERs now appear together at the bottom of the list
- Improved saved time calculations in Geckobaord reporting

### Added
- The Personal details sections has added fields:
  - Preferred language
  - Dietary requirements

### Fixed
- Fixed a bug which had stopped logging to Google Analytics
- Fixed a bug where long ethnicity information was spilling onto other page componens
- Fixed a bug where long prisoner names were not wrapping correctly in the sidebar


## 2018-01-02
### Changed
- Improved display where a question has multiple parts to the answer to make it more understandable.
- Improved wording in _Not for release_ section.
- Header now reads _Create or view a PER_.
- Improved display and interaction in _Offences_ section.
- Improved layout of alerts

### Added
- Added the wording _No known risks_ to sections with no risks to avoid ambiguity.
- Information on Single Signon added to healthcare endpoint

### Fixed
- No longer lists prisons that have ended in list of prisons in destination section.


## 2017-12-13
### Added
- Added the ability to cancel a PER after it has been issued so the destination can be informed.

### Changed
- Improvements to KPI calculations to enable us to more accurately assess how much time is being saved by the system.
- Better displaying of ACCT information when it has been closed to make it clearer.
- Clearer prompts when starting a PER to reduce confusion.
- Better warnings to help identify vunerable prisoners


## 2017-11
### Added
- New prison and court user types with relevant views and dashboards to simplify the user experience.
- New user roles with specific access to admin, healthcare etc. This allows safer access for different roles of user.
- Add numbers of previous convictions to assist assessment of risk level for offenders.
- New contact us form for reporting support issues.

### Changed
- Improved _Move information_ page. The _To_ section now has separate, auto complete fields for the different categories of destination.
- Improved the way offences are presented so they are clearer.
- Expand information on risks and health section so each item is visible.
- Clean up presentation of profile page so that key information can be seen more easily.
- Date of sexual offence is now optional. This is not always known.
- Flow of questions in risk section improved to streamline the user experience.
- Better self harm questions to help keep offenders safe.
- Improved the way offender information is displayed to aid identification.

### Fixed
- Various layout tweaks to fix minor presentation anomalies.
- Fixed a bug where self harm alerts were sometimes not showing.


## 2017-09-14
### Added
- Added a floating side bar displaying detainee and move details to ePER editing screens. This ensures that detainee and move details are visible at all stages of ePER creation.


## 2017-09-06
### Added
- Added new dosage and frequency fields to the _Essential Medication_ section of the ePER to improve how essential medication is administered.

### Changed
- Changes to the way cookies are created and stored to increase security.
