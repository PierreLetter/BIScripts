CREATE TABLE [dbo].[BlitzResults](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[CheckDate] [datetimeoffset](7) NULL,
	[Priority] [tinyint] NULL,
	[FindingsGroup] [varchar](50) NULL,
	[Finding] [varchar](200) NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[URL] [varchar](200) NULL,
	[Details] [nvarchar](4000) NULL,
	[QueryPlan] [nvarchar](max) NULL,
	[QueryPlanFiltered] [nvarchar](max) NULL,
	[CheckID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlitzResults] ADD  CONSTRAINT [PK_BlitzResults] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO