# Data Model: Monica iOS Client MVP

**Date**: 2025-10-26  
**Feature**: Monica iOS Client MVP  
**Source**: Monica OpenAPI specification in docs/monica-api-openapi.yaml

## Core Entities

### Contact

**Purpose**: Represents a person in the Monica CRM system

**Fields**:
- `id`: Integer (primary key)
- `first_name`: String (required)
- `last_name`: String? (optional)
- `nickname`: String? (optional) 
- `gender_id`: Integer? (optional, references gender lookup)
- `is_partial`: Boolean (indicates incomplete contact record)
- `is_dead`: Boolean (deceased status)
- `created_at`: Date (creation timestamp)
- `updated_at`: Date (last modification timestamp)

**Relationships**:
- One-to-many with Activity (contact can have multiple activities)
- One-to-many with Note (contact can have multiple notes)
- One-to-many with Task (contact can have multiple tasks)
- One-to-many with Gift (contact can have multiple gifts)
- Many-to-many with Tag (contact can have multiple tags)

**Business Rules**:
- `first_name` is mandatory
- Display name = `first_name + " " + last_name` or `first_name` if last_name is null
- Deceased contacts (`is_dead = true`) should have visual indicators
- Partial contacts (`is_partial = true`) may have limited information

**Validation**:
- `first_name` must not be empty
- `id` must be positive integer
- Dates must be valid ISO 8601 format

### Activity

**Purpose**: Represents an interaction or event related to one or more contacts

**Fields**:
- `id`: Integer (primary key)
- `activity_type_id`: Integer (references activity type lookup)
- `summary`: String (brief description)
- `description`: String? (detailed description, optional)
- `happened_at`: Date (when the activity occurred)
- `contacts`: [Integer] (array of contact IDs involved)

**Relationships**:
- Many-to-many with Contact (activity can involve multiple contacts)
- References activity type lookup table

**Business Rules**:
- Activities are always read-only in MVP
- Must have at least one associated contact
- Chronological ordering by `happened_at` (newest first)
- Activity types determine display icons/colors

**Validation**:
- `summary` must not be empty
- `happened_at` must be valid date
- `contacts` array must contain at least one valid contact ID
- `activity_type_id` must reference valid type

### Note

**Purpose**: Free-form text content associated with a contact

**Fields**:
- `id`: Integer (primary key)
- `contact_id`: Integer (foreign key to Contact)
- `body`: String (note content, required)
- `is_favorited`: Boolean (marked as favorite)

**Relationships**:
- Many-to-one with Contact (note belongs to one contact)

**Business Rules**:
- Notes are read-only in MVP
- Favorited notes should be visually distinguished
- Support for markdown or plain text display
- No length limit enforced in MVP

**Validation**:
- `body` must not be empty
- `contact_id` must reference valid contact

### Task

**Purpose**: To-do item or action item related to a contact

**Fields**:
- `id`: Integer (primary key)
- `contact_id`: Integer (foreign key to Contact)
- `title`: String (task title, required)
- `description`: String? (detailed description, optional)
- `completed`: Boolean (completion status)
- `completed_at`: Date? (completion timestamp, nullable)

**Relationships**:
- Many-to-one with Contact (task belongs to one contact)

**Business Rules**:
- Tasks are read-only in MVP
- Incomplete tasks should be shown before completed tasks
- `completed_at` should only be set when `completed = true`
- Tasks sorted by completion status, then by creation date

**Validation**:
- `title` must not be empty
- `contact_id` must reference valid contact
- If `completed = true`, `completed_at` should be present
- If `completed = false`, `completed_at` should be null

### Gift

**Purpose**: Gift ideas or given gifts for a contact

**Fields**:
- `id`: Integer (primary key)
- `contact_id`: Integer (foreign key to Contact)
- `name`: String (gift name, required)
- `comment`: String? (additional notes, optional)
- `is_an_idea`: Boolean (true = idea, false = given)
- `has_been_offered`: Boolean (whether gift was given)
- `url`: String? (URL to purchase or learn more, optional)
- `value`: Float? (estimated or actual cost, optional)

**Relationships**:
- Many-to-one with Contact (gift belongs to one contact)

**Business Rules**:
- Gifts are read-only in MVP
- Gift ideas (`is_an_idea = true`) should be visually distinguished from given gifts
- URLs should be tappable to open in Safari
- Value displayed in local currency format

**Validation**:
- `name` must not be empty
- `contact_id` must reference valid contact
- `url` must be valid URL format if provided
- `value` must be positive number if provided

### Tag

**Purpose**: Labels for categorizing and organizing contacts

**Fields**:
- `id`: Integer (primary key)
- `name`: String (tag display name, required)
- `name_slug`: String (URL-friendly version of name)

**Relationships**:
- Many-to-many with Contact (tags can be applied to multiple contacts)

**Business Rules**:
- Tags are read-only in MVP
- Tags should be displayed as colored badges/chips
- Tapping tag could filter contacts (future enhancement)
- Tag names should be unique per user

**Validation**:
- `name` must not be empty
- `name_slug` should match URL slug format
- Tag names should be case-insensitive unique

## API Response Wrappers

### APIResponse<T>

**Purpose**: Standard wrapper for all Monica API responses

**Fields**:
- `data`: T (actual response data, generic type)
- `meta`: PaginationMeta? (pagination information, optional)
- `links`: PaginationLinks? (pagination navigation links, optional)

**Usage**: Wraps all API responses for consistent handling

### PaginationMeta

**Purpose**: Metadata about paginated responses

**Fields**:
- `total`: Integer (total number of items across all pages)
- `current_page`: Integer (current page number, 1-indexed)
- `per_page`: Integer (items per page)

### PaginationLinks

**Purpose**: Navigation links for paginated responses

**Fields**:
- `first`: String? (URL to first page, nullable)
- `last`: String? (URL to last page, nullable)
- `prev`: String? (URL to previous page, nullable)
- `next`: String? (URL to next page, nullable)

**Business Rules**:
- Use `next` URL for "Load More" functionality
- `prev` will be null for first page
- `next` will be null for last page

## Display Models

### ContactDisplayModel

**Purpose**: Contact with computed display properties

**Computed Properties**:
- `displayName`: String (formatted full name)
- `initials`: String (first letter of first and last name)
- `lastInteractionDate`: String? (relative date format)
- `hasUpcomingBirthday`: Boolean (birthday within 30 days)

**Example**:
```swift
extension Contact {
    var displayName: String {
        if let lastName = last_name {
            return "\(first_name) \(lastName)"
        }
        return first_name
    }
    
    var initials: String {
        let firstInitial = String(first_name.prefix(1)).uppercased()
        let lastInitial = last_name?.prefix(1).uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
}
```

## Validation Rules Summary

### Field Validation
- **Required fields**: Contact.first_name, Activity.summary, Note.body, Task.title, Gift.name, Tag.name
- **Date fields**: Must be valid ISO 8601 format
- **URL fields**: Must be valid URL format if provided
- **Numeric fields**: Must be positive if provided
- **Foreign keys**: Must reference existing entities

### Business Logic Validation
- Completed tasks must have completion date
- Activities must have at least one associated contact
- Display names handle null last names gracefully
- Pagination metadata must be consistent with data array length

### Data Integrity Rules
- All entities require valid primary keys
- Foreign key references must exist
- Date consistency (created_at ≤ updated_at)
- Boolean flags must have consistent related data

## Caching Strategy

### In-Memory Cache Structure
```swift
struct ContactCache {
    var contacts: [Contact] = []
    var activities: [Int: [Activity]] = [:]  // contactId -> activities
    var notes: [Int: [Note]] = [:]           // contactId -> notes
    var tasks: [Int: [Task]] = [:]           // contactId -> tasks
    var gifts: [Int: [Gift]] = [:]           // contactId -> gifts
    var tags: [Tag] = []
    var lastUpdated: Date?
}
```

### Cache Invalidation Rules
- Clear cache on logout
- Refresh cache on pull-to-refresh
- 5-minute TTL for contact list
- Immediate invalidation on API errors (401, 403)
- Memory pressure handling with LRU eviction

## Error Handling for Data Layer

### Data Validation Errors
- Missing required fields
- Invalid date formats
- Malformed URLs
- Negative numeric values

### API Data Inconsistencies
- Missing referenced entities (orphaned foreign keys)
- Inconsistent pagination metadata
- Null values in required fields
- Date inconsistencies

### Recovery Strategies
- Skip invalid items with logging
- Use default values for optional fields
- Graceful degradation for display computations
- User-friendly error messages for critical failures

This data model provides a complete foundation for the Monica iOS Client MVP, ensuring type safety, validation, and proper relationship handling while maintaining simplicity for the read-only use case.