/*
SELECT
     CONCAT(rl.first_name,' ', rl.second_name, ' ', rl.patronymic) AS fio,
	 rd.name_of_region AS region,
     COUNT(sl.sale_code) as sales_count
FROM sale sl
JOIN real_estate_object reo On sl.object_code = reo.object_code
JOIN region rd ON rd.region_code = reo.region
JOIN realtor rl ON rl.realtor_code = sl.realtor_code
GROUP BY ROLLUP(rd.name_of_region, sl.sale_code, fio)


SELECT
      COALESCE (
             CASE
			     WHEN reo.number_of_rooms IS NULL THEN 0
				 ELSE reo.number_of_rooms
			 END,
			 0
	  ) AS rooms,
      COALESCE (
             CASE
			    WHEN rg.name_of_region IS NULL THEN 'empty'
				ELSE rg.name_of_region
			 END,
		     'все районы'
	  ) AS name_of_reg,
      ROUND(AVG(reo.cost_of_object / reo.square_of_building)::numeric, 2) AS mid_cost
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
GROUP BY ROLLUP (reo.number_of_rooms, rg.name_of_region)

SELECT
     COALESCE (
            CASE
			    WHEN ty.name_of_type IS NULL THEN 'итого по всем типам'
				WHEN reo.number_of_rooms IS NULL THEN CONCAT('всего по району: ', rg.name_of_region, '( ', ty.name_of_type, ' )')
				ELSE ty.name_of_type
			END,
			'все'
	 ) AS type_of_building,
	 COALESCE (
            CASE
			    WHEN rg.name_of_region IS NULL THEN '-'
				ELSE rg.name_of_region
			END,
			'-'
	 ) AS region,
	 COALESCE (
            CASE
			    WHEN reo.number_of_rooms IS NULL THEN 0
				ELSE reo.number_of_rooms
			END,
			0
	 ) AS region,
	 SUM(sl.cost_of_object) AS total_sum
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
JOIN sale sl ON sl.object_code = reo.object_code
JOIN type_of_object ty ON ty.type_code = reo.type_of_object
GROUP BY ROLLUP (ty.name_of_type, rg.name_of_region, reo.number_of_rooms)

SELECT
     COALESCE (
             CASE
			     WHEN CONCAT(rl.first_name,' ', rl.second_name, ' ', rl.patronymic) IS NULL THEN CONCAT('всего по району: ', rg.name_of_region)
				 ELSE CONCAT(rl.first_name,' ', rl.second_name, ' ', rl.patronymic)
			END,
			'итого по району'
	 ) AS fio,
     COALESCE (
            CASE
			    WHEN rg.name_of_region IS NULL THEN 'итого по районам'
				ELSE rg.name_of_region
			END,
			'итого по району'
	 ) AS region,
	 MAX(reo.cost_of_object - sl.cost_of_object) AS max_razn
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
JOIN sale sl ON sl.object_code = reo.object_code
JOIN realtor rl ON rl.realtor_code = sl.realtor_code
WHERE EXTRACT(YEAR FROM sl.date_of_selling) = '2025'
GROUP BY ROLLUP (rg.name_of_region, CONCAT(rl.first_name,' ', rl.second_name, ' ', rl.patronymic))

SELECT 
    COALESCE(EXTRACT(YEAR FROM sl.date_of_selling)::TEXT, 'итого по годам') AS years,
	COALESCE(reo.number_of_rooms::TEXT, 'итого по комнатам') AS rooms,
	COUNT(*) AS sales_count
FROM real_estate_object reo
JOIN sale sl ON sl.object_code = reo.object_code
WHERE
    reo.number_of_rooms = 2 AND
	sl.cost_of_object > (
    SELECT MAX(cost_of_object)
	FROM real_estate_object
	WHERE number_of_rooms = 2 AND type_of_object = 1
	)
GROUP BY GROUPING SETS(
     (sl.date_of_selling),
	 (reo.number_of_rooms),
	 (sl.date_of_selling, reo.number_of_rooms),
	 ()
)

SELECT
     COALESCE (
             CASE
			     WHEN EXTRACT(YEAR FROM sl.date_of_selling)::TEXT IS NULL THEN 'итого по гадам'
				 ELSE CAST(sl.date_of_selling AS VARCHAR)
			END, 
			'итого по гадам'
	 ) AS year_of_selling,
	 COALESCE (
             CASE
			     WHEN rg.name_of_region IS NULL THEN CONCAT('итого по году: ', sl.date_of_selling::TEXT)
				 ELSE rg.name_of_region
			END,
			CONCAT('итого по году: ', sl.date_of_selling::TEXT)
	 ) AS region,
	 ROUND(AVG(sl.cost_of_object / reo.number_of_rooms)::numeric, 2) AS avg_price_for_m
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
JOIN sale sl ON sl.object_code = reo.object_code
GROUP BY GROUPING SETS(
    (sl.date_of_selling),
	(sl.date_of_selling, rg.name_of_region),
	()
)

SELECT
     COALESCE (
            CASE
			    WHEN EXTRACT(YEAR FROM sl.date_of_selling)::TEXT IS NULL THEN 'итого по годам'
				ELSE CAST(sl.date_of_selling AS VARCHAR)
			END,
			'итого по годам'
	 ) AS years,
	 COALESCE (
            CASE
			    WHEN rg.name_of_region IS NULL THEN CONCAT('итого по году: ', sl.date_of_selling::TEXT)
				ELSE rg.name_of_region
			END,
			CONCAT('итого по году: ', sl.date_of_selling::TEXT)
	 ) AS region,
	 ROUND(AVG(reo.square_of_building)::numeric, 2) AS square
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
JOIN sale sl ON sl.object_code = reo.object_code
GROUP BY GROUPING SETS(
      (sl.date_of_selling),
	  (rg.name_of_region),
	  (sl.date_of_selling, rg.name_of_region),
	  ()
)
HAVING AVG(reo.square_of_building) >= 30

SELECT
     COALESCE(
              CASE
			      WHEN ty.name_of_type IS NULL THEN 'итого по всем типам'
				  ELSE ty.name_of_type
			  END,
			  'итого по всем типам'
	 ) AS type_of_building,
	 COALESCE(
             CASE
			     WHEN bu.name_of_material IS NULL THEN CONCAT('итого по типу: ', ty.name_of_type)
				 ELSE bu.name_of_material
			 END,
			 CONCAT('итого по типу: ', ty.name_of_type)
	 ) AS material,
	 COUNT(*) AS object_count
FROM real_estate_object reo
JOIN type_of_object ty ON ty.type_code = reo.type_of_object
JOIN building_materials bu ON bu.material_code = reo.building_materials
GROUP BY CUBE (ty.name_of_type, bu.name_of_material)

SELECT
     COALESCE(
	        CASE
			   WHEN rg.name_of_region IS NULL THEN 'итого по районам'
			   ELSE rg.name_of_region
			END,
			'итого по районам'
	 ) AS region,
	 COALESCE (
             CASE
			     WHEN ty.name_of_type IS NULL THEN CONCAT('итого по району: ', rg.name_of_region)
				 ELSE ty.name_of_type
			 END,
			 CONCAT('итого по району: ', rg.name_of_region)
	 ) AS type_of_building,
	 SUM(sl.cost_of_object) AS total_price
FROM real_estate_object reo
JOIN type_of_object ty ON ty.type_code = reo.type_of_object
JOIN sale sl ON sl.object_code = reo.object_code
JOIN region rg ON rg.region_code = reo.region
GROUP BY CUBE (rg.name_of_region, ty.name_of_type)

SELECT
    COALESCE(
           CASE
		       WHEN EXTRACT(YEAR FROM date_of_selling)::TEXT IS NULL THEN 'итого по годам'
			   ELSE CAST(EXTRACT(YEAR FROM date_of_selling) AS VARCHAR)
		   END,
		   'итого по годам'
	) AS years,
	COALESCE(
           CASE
		       WHEN EXTRACT(MONTH FROM date_of_selling)::TEXT IS NULL THEN CONCAT('итого по году: ', EXTRACT(YEAR FROM date_of_selling))
			   ELSE CAST(EXTRACT(MONTH FROM date_of_selling) AS VARCHAR)
		   END,
		   CONCAT('итого по году: ', EXTRACT(YEAR FROM date_of_selling))
	) AS months,
	SUM(cost_of_object) AS total_price
FROM sale
GROUP BY CUBE (EXTRACT(YEAR FROM date_of_selling), EXTRACT(MONTH FROM date_of_selling))
HAVING SUM(cost_of_object) >= 1000000

SELECT
     reo.address,
	 rg.name_of_region,
	 reo.cost_of_object,
	 MAX(reo.cost_of_object) OVER (PARTITION BY rg.name_of_region) AS max_price,
	 MAX(reo.cost_of_object) OVER (PARTITION BY rg.name_of_region) - reo.cost_of_object AS price_difference
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region

SELECT
    rg.name_of_region,
	reo.address,
	ty.name_of_type,
	ROUND((reo.cost_of_object / reo.number_of_rooms)::numeric, 2) AS price_m,
	ROUND(AVG(reo.cost_of_object / reo.number_of_rooms) OVER (PARTITION BY ty.name_of_type)::numeric, 2) AS avg_price,
	ROUND((reo.cost_of_object / reo.number_of_rooms)::numeric / AVG(reo.cost_of_object / reo.number_of_rooms) OVER (PARTITION BY ty.name_of_type)::numeric * 100, 2) AS percents
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
JOIN type_of_object ty ON ty.type_code = reo.type_of_object
WHERE reo.square_of_building > 0

SELECT
     reo.address,
	 reo.number_of_rooms,
	 sl.cost_of_object,
	 SUM(sl.cost_of_object) OVER (PARTITION BY reo.number_of_rooms) AS total_per_floor,
	 SUM(sl.cost_of_object) OVER (
       ORDER BY reo.number_of_rooms
	   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	 ) AS running_total
FROM real_estate_object reo
JOIN sale sl ON sl.object_code = reo.object_code
ORDER BY reo.number_of_rooms

SELECT
     reo.address,
	 rg.name_of_region,
	 ROUND((reo.cost_of_object / reo.number_of_rooms)::numeric, 2) AS price_m,
	 ROW_NUMBER() OVER (
               PARTITION BY rg.name_of_region
			   ORDER BY (reo.cost_of_object / reo.number_of_rooms) DESC
	 ) AS row_num_in_region,
	 COUNT(*) OVER (
          PARTITION BY rg.name_of_region
	 ) AS tota_flat_in_dis
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
WHERE reo.square_of_building > 0
ORDER BY
      rg.name_of_region,
	  price_m DESC

SELECT
     rl.second_name AS second_name,
	 COUNT(*) AS sales_count,
	 RANK() OVER (
          ORDER BY COUNT(*) DESC
	 ) AS sales_rank
FROM sale sl
JOIN realtor rl ON rl.realtor_code = sl.realtor_code
GROUP BY rl.second_name
ORDER BY rl.second_name

SELECT
     reo.address,
	 rg.name_of_region,
	 reo.cost_of_object,
	 LEAD(reo.cost_of_object, 2) OVER (ORDER BY rg.name_of_region ASC) AS price_two,
	 reo.cost_of_object - LEAD(reo.cost_of_object, 2) OVER (ORDER BY rg.name_of_region ASC) AS price_diff
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
ORDER BY rg.name_of_region ASC

CREATE TABLE price_history (
       id SERIAL PRIMARY KEY,
	   property_id INT NOT NULL,
	   new_price DECIMAL(15,2) DEFAULT 0,
	   change_date DATE DEFAULT CURRENT_DATE,
	   CONSTRAINT fk_property
	              FOREIGN KEY (property_id)
				  REFERENCES real_estate_object(object_code)
				  ON DELETE CASCADE
);

CREATE INDEX idx_price_history_property_date ON price_history(property_id, change_date);

INSERT INTO price_history (property_id, new_price, change_date) VALUES
(1, 5000000, '2024-01-11'),
(1, 11000000, '2024-02-15'),
(1, 8000000, '2024-10-13'),
(1, 15000000, '2024-11-01');

WITH pricediff AS (
      SELECT
	       property_id,
		   new_price,
		   change_date,
		   LAG(new_price) OVER (PARTITION BY property_id ORDER BY change_date) AS prev_price
	  FROM price_history
	  WHERE property_id = 1
),
changes AS (
      SELECT
	       change_date,
		   new_price,
		   prev_price,
		   (new_price - prev_price) AS price_change,
		    CASE
			    WHEN prev_price = 0 THEN NULL
				ELSE ROUND(((new_price - prev_price) * 1.0 / prev_price)::numeric * 100, 2)
		    END AS percent_change
	  FROM pricediff
	  WHERE prev_price IS NOT NULL
)

SELECT
     change_date AS date_of_change,
	 new_price AS new_object_price,
	 price_change AS change_of_price,
	 percent_change AS change_of_percent,
	 CASE
	     WHEN ABS(percent_change) > 20 THEN 'предупреждение: больше 20%'
		 ELSE NULL
	  END AS "предупреждение"
FROM changes
ORDER BY change_date

SELECT
     reo.address,
     rg.name_of_region,
	 reo.number_of_rooms,
	 reo.square_of_building,
	 LAST_VALUE(reo.square_of_building) OVER (
                PARTITION BY rg.name_of_region
				ORDER BY reo.number_of_rooms DESC
				ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	 ) AS last_square,
	 reo.square_of_building - LAST_VALUE(reo.square_of_building) OVER (
            PARTITION BY rg.name_of_region
			ORDER BY reo.number_of_rooms DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	 ) AS square_diff
FROM real_estate_object reo
JOIN region rg ON rg.region_code = reo.region
ORDER BY 
       rg.name_of_region,
	   reo.number_of_rooms DESC

SELECT
     reo.address,
	 ty.name_of_type,
	 reo.number_of_rooms,
	 sl.cost_of_object,
	 FIRST_VALUE(sl.cost_of_object) OVER (
              PARTITION BY ty.name_of_type
			  ORDER BY reo.number_of_rooms ASC
			  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	 ) AS first_price_type,
	 sl.cost_of_object - FIRST_VALUE(sl.cost_of_object) OVER (
             PARTITION BY ty.name_of_type
			 ORDER BY reo.number_of_rooms ASC
			 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	 ) AS price_diff
FROM real_estate_object reo
JOIN sale sl ON sl.object_code = reo.object_code
JOIN type_of_object ty ON ty.type_code = reo.type_of_object
ORDER BY
      ty.name_of_type,
	  reo.number_of_rooms ASC

SELECT
     rl.realtor_code,
	 CONCAT(rl.first_name,' ', rl.second_name, ' ', rl.patronymic),
	 sl.cost_of_object,
	 MAX(sl.cost_of_object) OVER (PARTITION BY rl.realtor_code) AS max_sl_price,
	 CASE
	    WHEN sl.cost_of_object = MAX(sl.cost_of_object) OVER (PARTITION BY rl.realtor_code) THEN 'Да'
		ELSE 'Нет'
	 END AS is_record_sale
FROM sale sl
JOIN realtor rl ON rl.realtor_code = sl.realtor_code
ORDER BY
      rl.realtor_code,
	  sl.cost_of_object DESC
*/

/*
CREATE TABLE Employers (
    EmployerID VARCHAR(200) PRIMARY KEY,
    CompanyName VARCHAR(200) NOT NULL,
    ActivityType VARCHAR(200) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone VARCHAR(200) NULL,

    CONSTRAINT UNQ_Employers_Phone UNIQUE (Phone)
);

CREATE TABLE ActivityTypes (
    ActivityTypeID VARCHAR(200) PRIMARY KEY,
    Consistency VARCHAR(200) NOT NULL,
    Specialization VARCHAR(150) NULL,
    QualificationReq TEXT NULL,
    LaborObject VARCHAR(200) NULL
);

CREATE TABLE Vacancies (
    VacancyID VARCHAR(200) PRIMARY KEY,
    PositionName VARCHAR(100) NOT NULL,
    CompanyDescription TEXT NULL,
    Requirements TEXT NULL,
    WorkConditions TEXT NULL,
    ContactInfo VARCHAR(200) NULL
);

CREATE TABLE JobSeekers (
    SeekerID VARCHAR(200) PRIMARY KEY,
    LastName VARCHAR(200) NOT NULL,
    FirstName VARCHAR(200) NOT NULL,
    Patronymic VARCHAR(200) NULL,
    Qualification VARCHAR(200) NULL,
    ActivityTypeID_Main VARCHAR(200) NULL,
    OtherInfo TEXT NULL,
    DesiredSalary INT CHECK (DesiredSalary >= 0)
);

CREATE TABLE Deals (
    DealID VARCHAR(200) PRIMARY KEY,
    SeekerID VARCHAR(200) NOT NULL,
    EmployerID VARCHAR(200) NOT NULL,
    Position_main VARCHAR(200) NOT NULL,
    Commission INT DEFAULT 0 CHECK (Commission >= 0)
);

CREATE TABLE Contracts (
    ContractID VARCHAR(200) PRIMARY KEY,
    CompanyID VARCHAR(200) NOT NULL,
    ContractName VARCHAR(200) NOT NULL UNIQUE,
    ContractNumber VARCHAR(200) NOT NULL,
    ConclusionDate DATE NOT NULL,

    CONSTRAINT UNQ_ContractNumber UNIQUE (ContractNumber)
);

INSERT INTO Employers (EmployerID, CompanyName, ActivityType, Address, Phone) VALUES
       ('ИНН 7736654639', 'Общество с ограниченной ответственностью "ЯНДЕКС"', '62.01 — Разработка компьютерного программного обеспечения', '119021, г. Москва, ул. Льва Толстого, д. 16', '+7 (495) 739-70-00'),
	   ('ИНН 2320106476', 'Публичное акционерное общество "Магнит"', '47.11 — Розничная торговля в неспециализированных магазинах преимущественно пищевыми продуктами, включая напитки, и табачными изделиями', '344019, Ростовская область, г. Ростов-на-Дону, ул. Камышовая, д. 1', '+7 (863) 333-55-00'),
	   ('ИНН 7736050003', 'Публичное акционерное общество "Газпром', '35.20 — Производство и распределение газообразного топлива по трубопроводам', '117997, г. Москва, ул. Наметкина, д. 16', '+7 (499) 719-30-01'),
	   ('ИНН 7745654680', 'ПАО "ТоргЛид"', '47.11 — Розничная торговля в неспециализированных магазинах преимущественно пищевыми продуктами', 'Тула, ул. Бородина, д. 32', '+7 (333) 739-30-22'),
	   ('ИНН 7736054369', 'ООО "ЦифМар"', '73.11 — Деятельность рекламных агентств', 'Великие Луки, ул. Горная, д. 33', 'Великие Луки, ул. Горная, д. 33'),
	   ('ИНН 7736027699', 'ООО "Модный Стиль"', '47.71 — Розничная торговля одеждой в специализированных магазинах', 'Севастополь, ул. Абазы, д. 10', '+7 (496) 752-71-21');

INSERT INTO JobSeekers (SeekerID, LastName, FirstName, Patronymic, Qualification, ActivityTypeID_Main, OtherInfo, DesiredSalary) VALUES
       ('RES-2025-023', 'Зубенко', 'Михаил', 'Петрович', 'Высшее образование (МГТУ им. Баумана, специальность "Программная инженерия"), сертификаты Python (Coursera), AWS Certified Developer', 'Разработка программного обеспечения (программист Python/Full-Stack)', 'Опыт работы 5 лет (2 года в ООО "ТехСофт" как Python-разработчик, 3 года в стартапе как Full-Stack разработчик), знание Python, JavaScript, Django, React, английский язык (B2)', 230000),
	   ('RES-2025-665', 'Сидоров', 'Сергей', 'Алексеевич', 'Среднее профессиональное образование (колледж торговли и сервиса), курсы по технике продаж', 'Розничная торговля (продавец-консультант в магазинах одежды или электроники)', 'Опыт работы 3 года в розничной сети "Модный стиль" (продавец-консультант), навыки работы с кассой, CRM-системами, умение консультировать клиентов, русский язык (родной)', 60000),
	   ('RES-2025-705', 'Игнатьев', 'Василий', 'Викторович', 'Высшее образование (СПбГТУ, специальность "Машиностроение"), сертификат AutoCAD и SolidWorks', 'Машиностроение и производство (инженер-конструктор или инженер-механик)', 'Опыт работы 7 лет (5 лет в ОАО "Машиностроительный завод" как инженер-конструктор, 2 года в проектной организации), знание AutoCAD, SolidWorks, английский язык (A2), разработка чертежей и 3D-моделей', 135000),
	   ('RES-2025-017', 'Зимин', 'Богдан', 'Анатольевич', 'Высшее образование (МФТИ, информатика), опыт работы 4 года в веб-разработке, знание JavaScript, React, Node.js, сертификат Full-Stack Developer (Coursera)', 'Разработка и поддержка веб — приложений (фронтенд и бэкенд) с использованием JavaScript, React и Node.js', 'Опыт работы 4 года в ООО «ТехноВебСолюшнс», Стажировка 3 месяца в ООО «Инновации Онлайн», участие в хакатонах (1-е местоб HackMIPT 2022), готовность к релокации и удаленной работе', 215000),
	   ('RES-2025-067', 'Осипов', 'Вадим', 'Богданович', 'Высшее образование (УрФУ, машиностроение), опыт работы 3 года инженером-конструктором, знание AutoCAD, SolidWorks, ЕСКД, сертификат SolidWorks Associate', 'Создание 3D-моделей и чертежей деталей и сборочных единиц с использованием AutoCaD и SolidWorks', 'Опыт работы 3 года в ООО «Машиностроительный завод», знание английского языка на уровне B1, сертификат SolidWorks Certified Associate (CSWA) Dassault Systemes, наличие водительских прав категории B', 115000),
	   ('RES-2025-709', 'Чернов', 'Ростислав', 'Витальевич', 'Высшее образование (СПбГУ, программирование), опыт работы 2 года в разработке мобильных приложений, знание Flutter, Dart, сертификат Google Developer', 'Разработка мобильных приложений, включая проектирование, кодирование, тестирование и интеграцию с серверной частью', 'Опыт работы 3 года в ООО «Мобайл Солюшенс», Стажер-разработчик 11 месяцев в ООО «ТехноСофт», сертификат Google Developer Cerrification, уровень английского B2', 200000);

INSERT INTO Deals (DealID, SeekerID, EmployerID, Position_main, Commission) VALUES
       ('1001', 'RES-2025-023', 'ИНН 7736654639', 'Python-разработчик (Full-Stack)', 300000),
	   ('1002', 'RES-2025-665', 'ИНН 2320106476', 'Продавец-консультант в супермаркете', 12000),
	   ('1003', 'RES-2025-705', 'ИНН 7736050003', 'Инженер-конструктор (машиностроение)', 180000),
	   ('1004', 'RES-2025-001', 'ИНН 7736654625', 'Разработчик компьютерного программного обеспечения', 150000),
	   ('1005', 'RES-2025-148', 'ИНН 7735536412', 'Инженер по автоматизации', 60000),
	   ('1006', 'RES-2025-015', 'ИНН 7736654642', 'Водитель-экспедитор', 120000);

INSERT INTO Vacancies (VacancyID, PositionName, CompanyDescription, Requirements, WorkConditions, ContactInfo) VALUES
       ('10010', 'Python-разработчик (Middle)', 'ООО "NewdayTech" — ведущий разработчик программного обеспечения для автоматизации бизнеса. Более 10 лет на рынке, офисы в Москве и Новосибирске, клиенты — крупные ритейлеры и банки. Компания разрабатывает решения на Python, Django и микросервисной архитектуре', 'Высшее техническое образование. Опыт работы от 3 лет в разработке на Python (Django/Flask). Знание SQL, REST API, Git. Опыт работы с Docker и CI/CD будет преимуществом. Английский язык на уровне чтения документации (A2–B1)', 'Зарплата: 180,000–250,000 рублей в месяц (до вычета НДФЛ). Формат: гибридный (2 дня в офисе в Москве, 3 дня удалённо). Полный соцпакет (ДМС, оплата отпусков, больничных). Корпоративное обучение, участие в хакатонах. График: 5/2, с 9:00 до 18:00 (гибкое начало)', 'Email: hr@techinnovations.ru Телефон: +7 (495) 123-45-67 Контактное лицо: Анна Смирнова, менеджер по персоналу Сайт: techinnovations.ru'),
	   ('10020', 'Продавец-консультант в магазин электроники', 'ООО "ЭлектроМир" — сеть магазинов электроники и бытовой техники с филиалами в 20 городах России. Более 5 лет на рынке, фокус на качественный сервис и обучение сотрудников. Центральный офис в Санкт-Петербурге.', 'Среднее или среднее профессиональное образование. Опыт работы в продажах от 1 года. Коммуникабельность, умение работать с клиентами. Знание техники продаж и кассовых операций будет преимуществом. Готовность к обучению', 'Зарплата: 45,000–65,000 рублей в месяц (оклад + премии за продажи). Формат: работа в магазине. График: сменный, 2/2, с 10:00 до 22:00. Оформление по ТК РФ, соцпакет (оплачиваемый отпуск, больничные). Скидки на продукцию компании', 'Email: jobs@electromir.ru Телефон: +7 (812) 987-65-43 Контактное лицо: Мария Иванова, HR-менеджер Сайт: electromir.ru'),
	   ('10030', 'Инженер-конструктор (механика)', 'АО "ПромМех" — производственное предприятие, специализирующееся на разработке и изготовлении оборудования для нефтегазовой отрасли. 15 лет на рынке, завод в Екатеринбурге, поставки по России и СНГ', 'Высшее образование (машиностроение, механика или смежные специальности). Опыт работы от 2 лет в проектировании (AutoCAD, SolidWorks). Знание ЕСКД (единая система конструкторской документации). Навыки 3D-моделирования и черчения. Ответственность, внимание к деталям', 'Зарплата: 100,000–140,000 рублей в месяц (до вычета НДФЛ). Формат: работа в офисе в Екатеринбурге, возможны редкие командировки. График: 5/2, с 8:00 до 17:00. Полный соцпакет (ДМС, корпоративный транспорт). Возможность карьерного роста до ведущего инженера', 'Email: career@mechanikaprom.ru Телефон: +7 (343) 555-12-34 Контактное лицо: Сергей Петров, руководитель отдела кадров Сайт: mechanikaprom.ru'),
	   ('10040', 'Учитель математики', 'Государственная общеобразовательная школа №15 в Москве — крупное образовательное учреждение с более чем 1000 учениками, специализирующееся на профильном обучении естественно-математическим направлениям', 'Высшее педагогическое образование по специальности «Математика» или смежное; опыт работы от 2 лет в школьном образовании; знание современных образовательных стандартов (ФГОС)', 'Полная занятость, график 5/2 с (8:00 до 15:00), зарплата от 80 000 рублей (оклад + премии за классное руководство), социальный пакет, возможность профессионального роста', 'Email: hr@school15.msk.ru телефон: +7 (495) 123-45-67 сайт: school15.msk.ru/vacancy'),
	   ('10050', 'Бухгалтер', 'ООО "ФинансПро" — средняя бухгалтерская фирма в Санкт-Петербурге, предоставляющая услуги по ведению учета для малого и среднего бизнеса (розничная торговля, IT-стартапы)', 'Высшее экономическое образование; опыт работы бухгалтером не менее 3 лет; уверенное владение 1С: Бухгалтерия 8.3 и MS Excel; знание российского налогового и бухгалтерского законодательства (НК РФ, ПБУ); навыки составления отчетности (баланс, НДС)', 'Полный день, график 5/2 (с 9:00 до 18:00); зарплата 90 000–120 000 руб.; удаленная работа возможна 2 дня в неделю; полный соцпакет', 'Email: jobs@finprospb.ru телефон: +7 (812) 987-65-43; сайт: finprospb.ru/career'),
	   ('10060', 'Менеджер по продажам', 'ЗАО "ТехноМаркет" — сеть розничных магазинов электроники в Екатеринбурге, с 20 филиалами по Уральскому региону. Компания специализируется на продаже гаджетов и бытовой техники', 'Высшее образование (маркетинг, экономика или смежное); опыт в продажах от 1 года (желательно в retail); навыки активных продаж и переговоров; знание CRM-систем (Bitrix24); коммуникабельность', 'Сменный график 5/2 (с 10:00 до 19:00); зарплата 70 000 руб. (оклад) + 30–50% от продаж (итого до 150 000 руб.); бонусы за перевыполнение плана; обучение за счет компании; корпоративный транспорт и питание', 'Email: hr@technomarket66.ru телефон: +7 (343) 210-98-76 сайт: technomarket66.ru/jobs');

INSERT INTO ActivityTypes (ActivityTypeID, Consistency, Specialization, QualificationReq, LaborObject) VALUES
       ('110', 'Постоянная', 'Программист (Python-разработчик, Full-Stack разработчик). Специализация в создании и поддержке веб-приложений, API, серверных систем', 'Высшее техническое образование Знание языков программирования (Python, JavaScript, SQL). Опыт работы с фреймворками (Django, Flask, React) от 2–5 лет. Навыки работы с Git, Docker, CI/CD. Сертификаты (Python Institute, AWS) — преимущество. Английский язык на уровне B1–B2 для чтения документации', 'Программный код, базы данных, API, веб-интерфейсы, серверные приложения'),
	   ('120', 'Постоянная с элементами периодичности', 'Продавец-консультант в розничной торговле Специализация в консультировании клиентов и продвижении товаров', 'Среднее или среднее профессиональное образование. Опыт работы в продажах от 0–2 лет (можно без опыта). Навыки общения, клиентоориентированность, стрессоустойчивость. Знание кассовых систем и CRM (1С или Битрикс24) — преимущество. Базовые навыки работы с ПК', 'Клиенты, товары'),
	   ('130', 'Постоянная с проектной спецификой', 'Инженер-конструктор (механика, машиностроение). Специализация в проектировании деталей, узлов и механизмов для промышленного оборудования', 'Высшее образование (машиностроение, механика, энергетика). Опыт работы от 2–5 лет в проектировании. Знание AutoCAD, SolidWorks, Компас-3D. Понимание ЕСКД (стандарты конструкторской документации). Навыки 3D-моделирования и расчётов прочности. Английский язык (A2–B1) для работы с технической документацией — преимущество', 'Чертежи, 3D-модели, техническая документация, оборудование'),
	   ('140', 'Ежедневная работа с графиком 8 часов, 5 дней в неделю, с регулярными проверками качества продукции', 'Кондитерское производство', 'Среднее профессиональное образование (техникум или колледж по специальности "Технология пищевого производства") или опыт работы от 2 лет; знание рецептур и технологий приготовления кондитерских изделий; умение работать с профессиональным оборудованием (печи, миксеры); сертификаты по санитарии и гигиене пищевого производства', 'Выпечка для розничной продажи и оптовых заказов'),
	   ('150', 'Постоянная работа с цикличностью проектов (от 1 до 3 месяцев), с ежедневным мониторингом и еженедельным отчетом', 'Ландшафтный дизайн', 'Высшее образование в области ландшафтной архитектуры или агрономии; опыт работы от 3 лет; знание ботаники, проектирования садов и парков; владение программами AutoCAD, SketchUp; навыки управления малой строительной техникой', 'декоративные элементы (скамейки, фонтаны) для частных садов и общественных территорий'),
	   ('160', 'Работа с сезонным графиком (весна-осень), 6-часовые смены 6 дней в неделю, с периодическими выездами на объект', 'Реставрация исторических зданий', 'Среднее специальное или высшее образование в области реставрации или строительства; опыт работы от 5 лет; знание технологий реставрации; владение ручными инструментами и базовыми навыками работы с известью и гипсом; сертификаты по охране памятников культуры', 'Исторические фасады, интерьеры, декоративные элементы (фрески, лепнина) зданий, включенных в реестр культурного наследия');

INSERT INTO Contracts (ContractID, CompanyID, ContractName, ContractNumber, ConclusionDate) VALUES
       ('TD-2025-031', 'ИНН 7736654639', 'Трудовой договор с Python-разработчиком', 'ТД-001/2025', '2025-09-01'),
	   ('TD-2025-105', 'ИНН 2320106476', 'Трудовой договор с продавцом-консультантом', 'ТД-123/2025', '2025-08-15'),
	   ('TD-2025-338', 'ИНН 7736050003', 'Трудовой договор с инженером-конструктором', 'ТД-045/2025', '2025-07-20'),
	   ('TD-2025-725', 'ИНН 7736654633', 'Трудовой договор с веб-дизайнером', 'ТД-097/2025', '2025-05-01'),
	   ('TD-2025-200', 'ИНН 7736654125', 'Трудовой договор с аналитиком данных', 'ТД-333/2025', '2025-04-30'),
	   ('TD-2025-001', 'ИНН 7736654777', 'Трудовой договор с маркетологом по контенту', 'ТД-060/2025', '2025-02-23');

*/

/*
SELECT
     EXTRACT (YEAR FROM ConclusionDate) AS year_now,
	 EXTRACT (MONTH FROM ConclusionDate) AS month_now,
	 COUNT(*) AS contract_counts
FROM Contracts
GROUP BY year_now, month_now
HAVING COUNT(*) = 1
ORDER BY year_now, month_now;


SELECT
     emp.companyname AS name_of_company,
	 COUNT(del.dealid) AS deal_count,
	 SUM(del.commission) AS total_commissions
FROM Employers emp
JOIN Deals del ON del.employerid = emp.employerid
GROUP BY emp.companyname
HAVING COUNT(del.dealid) = 1 AND SUM(del.commission) > 50000;


SELECT
      emp.companyname AS name_of_company,
	  emp.employerid AS id_of_employer,
	  MAX(del.commission) AS max_commission
FROM Employers emp
JOIN Deals del ON del.employerid = emp.employerid
GROUP BY emp.companyname, emp.employerid
HAVING MAX(del.commission) > 25000;



SELECT
      patronymic,
	  lastname,
	  firstname,
	  desiredsalary
FROM Jobseekers
WHERE desiredsalary > (SELECT AVG(desiredsalary) FROM Jobseekers);


SELECT
     companyname AS name_of_company
FROM employers emp
WHERE EXISTS (
      SELECT 1
	  FROM deals del
	  WHERE del.employerid = emp.employerid AND del.commission > 100000
);


SELECT
     emp.companyname,
	 SUM(del.commission) AS total_comission
FROM Employers emp
JOIN Deals del ON del.employerid = emp.employerid
GROUP BY ROLLUP (emp.companyname)


SELECT
      emp.companyname,
	  del.position_main AS position_main,
	  SUM(del.commission) AS total_comission
FROM Employers emp
JOIN Deals del ON del.employerid = emp.employerid
GROUP BY CUBE(emp.companyname, del.position_main);


SELECT
     emp.companyname,
	 job.activitytypeid_main,
	 COUNT(*) AS deal_count
FROM Deals del
JOIN Employers emp ON del.employerid = emp.employerid
JOIN Jobseekers job ON del.seekerid = job.seekerid
GROUP BY GROUPING SETS (
      (emp.companyname),
	  (job.activitytypeid_main),
	  ()
)


SELECT
     seekerid,
	 lastname,
	 firstname,
	 desiredsalary,
	 RANK() OVER (ORDER BY	 desiredsalary DESC) AS salary_rank
FROM jobseekers


SELECT
     dealid,
	 seekerid,
	 commission,
	 LAG(commission) OVER (PARTITION BY seekerid ORDER BY dealid) AS prev_commission,
	 LEAD(commission) OVER (PARTITION BY seekerid ORDER BY dealid) AS next_commission
FROM deals

SELECT
     emp.companyname,
	 del.dealid,
	 del.commission,
	 SUM(del.commission) OVER (PARTITION BY emp.employerid ORDER BY del.dealid) AS running_total
FROM Employers emp
JOIN Deals del ON del.employerid = emp.employerid;


SELECT
    seekerid,
	lastname || ' ' || firstname AS full_name,
	desiredsalary,
	CASE
	    WHEN desiredsalary >= 30000 THEN 'high'
		WHEN desiredsalary >= 20000 THEN 'middle'
		WHEN desiredsalary >= 10000 THEN 'low'
		ELSE 'the lowest'
	END AS salary_level
FROM jobseekers
*/

WITH TopDeals AS (
     SELECT
	       del.dealid,
		   del.position_main,
		   del.commission,
		   job.lastname || ' ' || job.firstname AS full_name,
		   emp.companyname,
		   ROW_NUMBER() OVER (ORDER BY del.commission DESC) AS rn
	FROM Deals del
	JOIN Employers emp ON del.employerid = emp.employerid
	JOIN Jobseekers job ON del.seekerid = job.seekerid
)
SELECT
      dealid,
	  position_main,
	  commission,
	  full_name,
	  companyname
FROM TopDeals
WHERE rn <= 3;

